//
//  EmojiPhotoAlertController.swift
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

import Photos
import UIKit

extension UIAlertController {
    
    enum EmojiPhotoChoice {
        case photos, camera, emoji, error(UIViewController)
    }
    
    static let emojiLocalizedString = "Emoji"
    
    class var photosLocalizedString: String {
        return "Photos"
    }
    
    class var cameraLocalizedString: String {
        switch SelfContainedImagePickerController.cameraPermission {
        case .authorized, .notDetermined:
            return "Camera"
        case .denied, .restricted:
            return "Camera 🔒"
        }
    }
    
    class func emojiPhotoActionSheet(completionHandler: @escaping (EmojiPhotoChoice) -> Void) -> UIAlertController {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let emoji = UIAlertAction(title: self.emojiLocalizedString, style: .default) { _ in completionHandler(.emoji) }
        let photo = UIAlertAction(title: self.photosLocalizedString, style: .default) { _ in completionHandler(.photos) }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertVC.addAction(emoji)
        let front = UIImagePickerController.isCameraDeviceAvailable(.front)
        let rear = UIImagePickerController.isCameraDeviceAvailable(.rear)
        if front || rear {
            let camera = UIAlertAction(title: self.cameraLocalizedString, style: .default) { _ in
                switch SelfContainedImagePickerController.cameraPermission {
                case .authorized, .notDetermined:
                    completionHandler(.camera)
                case .restricted:
                    let errorVC = self.cameraRestrictedAlert()
                    completionHandler(.error(errorVC))
                case .denied:
                    let errorVC = self.cameraDeniedAlert()
                    completionHandler(.error(errorVC))
                }
            }
            alertVC.addAction(camera)
        }
        alertVC.addAction(photo)
        alertVC.addAction(cancel)
        return alertVC
    }
    
    class func cameraRestrictedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: "Camera Restricted", message: "WaterMe cannot access your camera. This feature has been restricted by this device's administrator.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cancel)
        return alertVC
    }
    
    class func cameraDeniedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: "Permission Denied", message: "WaterMe cannot access your camera. You can grant access in Settings", preferredStyle: .alert)
        let settings = UIAlertAction(title: "Settings", style: .default) { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(settings)
        alertVC.addAction(cancel)
        return alertVC
    }
}
