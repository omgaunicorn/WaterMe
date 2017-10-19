//
//  ReminderCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 08/10/17.
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

import Result
import RealmSwift
import WaterMeData
import UIKit

protocol ReminderCollectionViewControllerDelegate: class {
    func userDidSelectReminder(with identifier: Reminder.Identifier, deselectAnimated: @escaping (Bool) -> Void, within viewController: ReminderCollectionViewController)
}

class ReminderCollectionViewController: StandardCollectionViewController, HasBasicController, HasProController {
    
    var proRC: ProController?
    var basicRC: BasicController?
    
    var data: Result<AnyRealmCollection<Reminder>, RealmError>?

    weak var delegate: ReminderCollectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.dragInteractionEnabled = true // needed for iphone
        self.collectionView?.dragDelegate = self
        self.collectionView?.register(ReminderCollectionViewCell.nib, forCellWithReuseIdentifier: ReminderCollectionViewCell.reuseID)
        self.flow?.minimumInteritemSpacing = 0
        self.hardReloadData()
    }
    
    private func hardReloadData() {
        self.notificationToken?.stop()
        self.notificationToken = nil
        self.data = nil
        
        guard let result = self.basicRC?.allReminders() else { return }
        switch result {
        case .failure:
            self.data = result
        case .success(let collection):
            self.notificationToken = collection.addNotificationBlock({ [weak self] changes in self?.dataChanged(changes) })
        }
    }
    
    private func dataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<Reminder>>) {
        switch changes {
        case .initial(let data):
            self.data = .success(data)
            self.collectionView?.reloadData()
        case .update(_, deletions: let del, insertions: let ins, modifications: let mod):
            self.collectionView?.performBatchUpdates({
                self.collectionView?.insertItems(at: ins.map({ IndexPath(row: $0, section: 0) }))
                self.collectionView?.deleteItems(at: del.map({ IndexPath(row: $0, section: 0) }))
                self.collectionView?.reloadItems(at: mod.map({ IndexPath(row: $0, section: 0) }))
            }, completion: nil)
        case .error(let error):
            log.error(error)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ReminderGedeg.numberOfSections(for: self.data?.value) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ReminderGedeg.numberOfItems(inSection: section, for: self.data?.value) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReminderCollectionViewCell.reuseID, for: indexPath)
        let reminder = ReminderGedeg.reminder(at: indexPath, in: self.data?.value)
        if let reminder = reminder, let cell = cell as? ReminderCollectionViewCell {
            cell.configure(with: reminder)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let reminder = ReminderGedeg.reminder(at: indexPath, in: self.data?.value) else { return }
        self.delegate?.userDidSelectReminder(with: .init(reminder: reminder),
                                             deselectAnimated: { collectionView.deselectItem(at: indexPath, animated: $0) },
                                             within: self)

    }

    override var columnCount: Int {
        let accessibility = UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        let horizontalClass = self.view.traitCollection.horizontalSizeClass
        switch (horizontalClass, accessibility) {
        case (.unspecified, _):
            assertionFailure("Hit a size class this VC was not expecting")
            fallthrough
        case (.regular, false):
            return 2
        case (.regular, true):
            return 1
        case (.compact, false):
            return 2
        case (.compact, true):
            return 1
        }
    }

    override var itemHeight: CGFloat {
        return 180
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
    
}

extension ReminderCollectionViewController: UICollectionViewDragDelegate {

    private func dragItemForReminder(at indexPath: IndexPath) -> UIDragItem? {
        guard let reminder = ReminderGedeg.reminder(at: indexPath, in: self.data?.value) else { return nil }
        let item = UIDragItem(itemProvider: NSItemProvider())
        item.localObject = Reminder.Identifier(reminder: reminder)
        return item
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [self.dragItemForReminder(at: indexPath)].flatMap({ $0 })
    }

    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return [self.dragItemForReminder(at: indexPath)].flatMap({ $0 })
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        return false
    }
}

extension ReminderCollectionViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popController: UIPopoverPresentationController) {
        let selectedIndexPath = self.collectionView?.indexPathsForSelectedItems?.last ?? IndexPath(row: 0, section: 0)
        let selectedView = self.collectionView?.cellForItem(at: selectedIndexPath) ?? self.view
        popController.sourceView = selectedView
        popController.sourceRect = selectedView?.frame ?? .zero
    }
}
