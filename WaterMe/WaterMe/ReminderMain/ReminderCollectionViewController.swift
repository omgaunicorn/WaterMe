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
    func userDidSelect(reminder: Reminder, from view: UIView, deselectAnimated: @escaping (Bool) -> Void, within viewController: ReminderCollectionViewController)
    func dragSessionWillBegin(_ session: UIDragSession, within viewController: ReminderCollectionViewController)
    func dragSessionDidEnd(_ session: UIDragSession, within viewController: ReminderCollectionViewController)
}

class ReminderCollectionViewController: StandardCollectionViewController, HasBasicController, HasProController {
    
    var proRC: ProController?
    var basicRC: BasicController?

    private(set) var reminders: ReminderGedeg?
    private let significantTimePassedDetector = SignificantTimePassedDetector()
    
    weak var delegate: ReminderCollectionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.flow?.sectionHeadersPinToVisibleBounds = true
        self.collectionView?.dragInteractionEnabled = true // needed for iphone
        self.collectionView?.dragDelegate = self
        self.collectionView?.register(ReminderCollectionViewCell.nib,
                                      forCellWithReuseIdentifier: ReminderCollectionViewCell.reuseID)
        self.collectionView?.register(ReminderHeaderCollectionReusableView.self,
                                      forSupplementaryViewOfKind: ReminderHeaderCollectionReusableView.kind,
                                      withReuseIdentifier: ReminderHeaderCollectionReusableView.reuseID)
        self.flow?.minimumInteritemSpacing = 0
        self.flow?.minimumLineSpacing = 0
        self.significantTimePassedDetector.delegate = self
        self.hardReloadData()
    }
    
    private func hardReloadData() {
        self.reminders = ReminderGedegDataSource(basicRC: self.basicRC, managedCollectionView: self.collectionView)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.reminders?.numberOfSections() ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reminders?.numberOfItems(inSection: section) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReminderCollectionViewCell.reuseID, for: indexPath)
        let reminder = self.reminders?.reminder(at: indexPath)
        if let reminder = reminder, let cell = cell as? ReminderCollectionViewCell {
            cell.configure(with: reminder)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ReminderHeaderCollectionReusableView.kind,
                                                                     withReuseIdentifier: ReminderHeaderCollectionReusableView.reuseID,
                                                                     for: indexPath)
        if let header = header as? ReminderHeaderCollectionReusableView, let section = Reminder.Section(rawValue: indexPath.section) {
            header.setSection(section)
        }
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // we don't want the user to be able to select a cell when a drag is active
        guard collectionView.hasActiveDrag == false else { return false }
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let reminder = self.reminders?.reminder(at: indexPath), let cell = collectionView.cellForItem(at: indexPath) else { return }
        self.delegate?.userDidSelect(reminder: reminder,
                                     from: cell,
                                     deselectAnimated: { collectionView.deselectItem(at: indexPath, animated: $0) },
                                     within: self)
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? ReminderCollectionViewCell
        cell?.willDisplay()
    }

    override var columnCountAndItemHeight: (columnCount: Int, itemHeight: CGFloat) {
        let accessibility = UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        let horizontalClass = self.view.traitCollection.horizontalSizeClass
        let verticalClass = self.view.traitCollection.verticalSizeClass
        switch (horizontalClass, verticalClass, accessibility) {
        case (.unspecified, _, _), (_, .unspecified, _):
            assertionFailure("Hit a size class this VC was not expecting")
            fallthrough
        case (.compact, .regular, false): // iPhone Portrait, no Accessibility
            return (2, 200)
        case (.compact, .regular, true): // iPhone Portrait, w/ Accessibility
            return (1, 320)
        case (.compact, .compact, false): // iPhone Landscape, no Accessibility
            return (2, 200)
        case (.compact, .compact, true): // iPhone Landscape, w/ Accessibility
            return (1, 320)
        case (.regular, .compact, false): // iPhone+ Landscape, no Accessibility
            return (3, 200)
        case (.regular, .compact, true): // iPhone+ Landscape, w/ Accessibility
            return (2, 320)
        case (.regular, .regular, false): // iPad No Accessibility
            return (4, 200)
        case (.regular, .regular, true): // iPad w/ Accessibility
            return (2, 320)
        }
    }
}

extension ReminderCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let kind = ReminderHeaderCollectionReusableView.self
        guard let reminders = self.reminders, reminders.numberOfItems(inSection: section) > 0 else {
            // if I return height of 0 here, things crash
            // instead I'll just have to set the alpha to 0
            return CGSize(width: collectionView.availableContentSize.width, height: 1)
        }
        let isAC = UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        return CGSize(width: collectionView.availableContentSize.width, height: kind.style_viewHeight(isAccessibilityCategory: isAC))
    }
}

extension ReminderCollectionViewController: UICollectionViewDragDelegate {

    private func dragItemForReminder(at indexPath: IndexPath) -> UIDragItem? {
        guard let reminder = self.reminders?.reminder(at: indexPath) else { return nil }
        let item = UIDragItem(itemProvider: NSItemProvider())
        // only make the "small" preview show on iPhones. On iPads, there is plenty of space
        switch (self.view.traitCollection.horizontalSizeClass, self.view.traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            break // do nothing for ipads
        default:
            item.previewProvider = { ReminderDragPreviewView.dragPreview(for: reminder) }
        }
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

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        let p = UIDragPreviewParameters()
        p.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: UIApplication.style_cornerRadius)
        return p
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        self.delegate?.dragSessionWillBegin(session, within: self)
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        self.delegate?.dragSessionDidEnd(session, within: self)
    }
}

extension ReminderCollectionViewController: SignificantTimePassedDetectorDelegate {
    func significantTimePassed(with reason: SignificantTimePassedDetector.Reason) {
        let event: Analytics.Event
        switch reason {
        case .BackupDetector:
            event = .stpReloadBackup
        case .STCNotification:
            event = .stpReloadNotification
        }
        Analytics.log(event: event)
        Analytics.log(event: Analytics.Event.stpReloadNotification)
        log.info("Reloading Data: " + Analytics.Event.stpReloadBackup.rawValue)
        self.hardReloadData()
    }
}
