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

import MobileCoreServices
import Photos
import UIKit

class SelfContainedImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    class var cameraPermission: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
    }
    
    class var photosPermission: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    private class func newVC(completionHandler: @escaping (UIImage?, UIViewController) -> Void) -> SelfContainedImagePickerController {
        let vc = SelfContainedImagePickerController()
        vc.completionHandler = completionHandler
        vc.modalPresentationStyle = .pageSheet
        vc.delegate = vc
        vc.allowsEditing = true
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
            let invalidateTimer = {
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
                switch type(of: self).photosPermission {
                case .notDetermined:
                    break // do nothing. the user needs to pick
                case .authorized:
                    invalidateTimer()
                case .restricted, .denied:
                    invalidateTimer()
                    self.completionHandler?(nil, self)
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.completionHandler?(image, self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.completionHandler?(nil, self)
    }
    
    deinit {
        self.permissionCheckTimer?.invalidate()
    }
    
}
