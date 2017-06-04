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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import MobileCoreServices
import Photos
import UIKit

class SelfContainedImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    class func newPhotosVC(completionHandler: @escaping (UIImage?, UIViewController) -> Void) -> UIViewController {
        let vc = SelfContainedImagePickerController()
        vc.completionHandler = completionHandler
        vc.modalPresentationStyle = .pageSheet
        vc.delegate = vc
        vc.allowsEditing = false
        vc.sourceType = .photoLibrary
        vc.mediaTypes = [kUTTypeImage as String]
        return vc
    }
    
    var completionHandler: ((UIImage?, UIViewController) -> Void)?
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.completionHandler?(image, self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.completionHandler?(nil, self)
    }
    
}
