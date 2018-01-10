//
//  SelfContainedImagePickerController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/3/17.
//  Copyright © 2017 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import CropViewController
import MobileCoreServices
import Photos
import UIKit

class ImagePickerCropperViewController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    class var cameraPermission: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    private class func newVC(completionHandler: @escaping (UIImage?, UIViewController) -> Void) -> ImagePickerCropperViewController {
        let vc = ImagePickerCropperViewController()
        vc.completionHandler = completionHandler
        vc.modalPresentationStyle = .overFullScreen
        vc.imageExportPreset = .compatible
        vc.delegate = vc
        vc.allowsEditing = false
        vc.mediaTypes = [kUTTypeImage as String]
        return vc
    }
    
    class func newPhotosVC(completionHandler: @escaping (UIImage?, UIViewController) -> Void) -> UIViewController {
        let vc = self.newVC(completionHandler: completionHandler)
        vc.sourceType = .photoLibrary
        return vc
    }
    
    class func newCameraVC(completionHandler: @escaping (UIImage?, UIViewController) -> Void) -> UIViewController {
        let vc = self.newVC(completionHandler: completionHandler)
        vc.sourceType = .camera
        return vc
    }
    
    var completionHandler: ((UIImage?, UIViewController) -> Void)?
    private var permissionCheckTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.sourceType == .photoLibrary {
            // makes it so when the screen first launches
            // and user has not given permission yet
            // the VC is white rather than black
            self.view.backgroundColor = .white
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard self.permissionCheckTimer == nil else { return }
        self.permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            func invalidateTimer() {
                timer.invalidate()
                self.permissionCheckTimer?.invalidate()
                self.permissionCheckTimer = nil
            }
            switch self.sourceType {
            case .camera:
                switch type(of: self).cameraPermission {
                case .notDetermined:
                    break // do nothing. the user needs to pick
                case .authorized:
                    invalidateTimer()
                case .restricted, .denied:
                    invalidateTimer()
                    self.completionHandler?(nil, self)
                }
            case .photoLibrary, .savedPhotosAlbum:
                invalidateTimer() // iOS 11 makes photos permission no longer needed for UIImagePickerController
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let original = info[UIImagePickerControllerOriginalImage] as? UIImage
        guard let image = original else { self.completionHandler?(nil, picker); return; }
        let crop = CropViewController(croppingStyle: .default, image: image)
        crop.aspectRatioPickerButtonHidden = true
        crop.aspectRatioPreset = .presetSquare
        crop.aspectRatioLockEnabled = true
        crop.delegate = self
        self.present(crop, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.completionHandler?(nil, self)
    }
    
    deinit {
        self.permissionCheckTimer?.invalidate()
    }
}

extension ImagePickerCropperViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.completionHandler?(image, self)
        }
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
