//
//  ReminderVesselEditViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/2/17.
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

import RealmSwift
import WaterMeData
import UIKit

class ReminderVesselEditViewController: UIViewController, HasBasicController {
    
    typealias CompletionHandler = (UIViewController) -> Void
    
    class func newVC(
        basicRC: BasicController?,
        editVessel vessel: ReminderVessel? = nil,
        completionHandler: @escaping CompletionHandler
        ) -> UIViewController
    {
        let sb = UIStoryboard(name: "ReminderVesselEdit", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderVesselEditViewController
        vc.configure(with: basicRC)
        vc.completionHandler = completionHandler
        if let vessel = vessel {
            vc.editable = vessel.editable()
            vc.notificationToken = vessel.addNotificationBlock({ vc.vesselChanged($0, vessel) })
        }
        return navVC
    }
    
    /*@IBOutlet*/ private weak var tableViewController: ReminderVesselEditTableViewController?
    
    var basicRC: BasicController?
    var editable = ReminderVessel.Editable()
    var completionHandler: CompletionHandler?
    
    private func vesselChanged(_ changes: ObjectChange, _ vessel: ReminderVessel) {
        switch changes {
        case .change:
            self.editable = vessel.editable()
            self.tableViewController?.tableView.reloadData()
        case .deleted, .error:
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateIcon(_ icon: ReminderVessel.Icon, andReloadTable reload: Bool = true) {
        self.editable.icon = icon
        guard reload else { return }
        self.tableViewController?.tableView.reloadData()
    }
    
    private func updateDisplayName(_ name: String, andReloadTable reload: Bool = false) {
        self.editable.displayName = name
        guard reload else { return }
        self.tableViewController?.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Plant"
        
        self.tableViewController = self.childViewControllers.first()
        self.tableViewController?.editableFromDataSource = { [unowned self] in return self.editable }
        self.tableViewController?.choosePhotoTapped = { [unowned self] in self.presentEmojiPhotoActionSheet() }
        self.tableViewController?.displayNameChanged = { [unowned self] newValue in self.updateDisplayName(newValue) }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: NSObject?) {
        self.notificationToken?.stop()
        self.completionHandler?(self)
    }
    
    @IBAction private func saveButtonTapped(_ sender: NSObject?) {
        guard let basicRC = self.basicRC else { return }
        let result = basicRC.updateReminderVessel(with: self.editable)
        switch result {
        case .success:
            self.notificationToken?.stop()
            self.completionHandler?(self)
        case .failure(let error):
            log.error(error)
        }
    }
    
    private func presentEmojiPhotoActionSheet() {
        let vc = UIAlertController.emojiPhotoActionSheet() { choice in
            switch choice {
            case .camera:
                let vc = SelfContainedImagePickerController.newCameraVC() { image, vc in
                    vc.dismiss(animated: true, completion: nil)
                    guard let image = image else { return }
                    self.updateIcon(ReminderVessel.Icon(rawImage: image))
                }
                self.present(vc, animated: true, completion: nil)
            case .photos:
                let vc = SelfContainedImagePickerController.newPhotosVC() { image, vc in
                    vc.dismiss(animated: true, completion: nil)
                    guard let image = image else { return }
                    self.updateIcon(ReminderVessel.Icon(rawImage: image))
                }
                self.present(vc, animated: true, completion: nil)
            case .emoji:
                let vc = EmojiPickerViewController.newVC() { emoji, vc in
                    vc.dismiss(animated: true, completion: nil)
                    guard let emoji = emoji else { return }
                    self.updateIcon(.emoji(emoji))
                }
                self.present(vc, animated: true, completion: nil)
            case .error(let errorVC):
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
        log.debug()
    }
}
