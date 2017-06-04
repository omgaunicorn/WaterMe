//
//  SynchronizingViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/25/17.
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
import UIKit

class SynchronizingViewController: LoadingViewController {
    
    private let adminController = AdminRealmController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stop()
        let receipts = self.adminController.allReceiptFiles()
        self.notificationToken = receipts.addNotificationBlock() { [weak self] changes in self?.realmDataChanged(changes) }
    }
    
    private func realmDataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<RealmFile>>) {
        switch changes {
        case .initial, .update:
            self.updateSyncSessionProgressNotifications()
        case .error(let error):
            log.error(error)
        }
    }
    
    private func updateSyncSessionProgressNotifications() {
        guard let user = SyncUser.current else { log.info("Realm User Not Logged In"); return }
        self.progressTokens = nil
        let sessions = user.allSessions()
        self.progressTokens = sessions.flatMap() { session -> SyncSession.ProgressNotificationToken? in
            return session.addProgressNotification(for: .download, mode: .reportIndefinitely) { [weak self] progress in
                if progress.isTransferComplete {
                    self?.stop()
                } else {
                    self?.start()
                }
            }
        }
    }
    
    override func start() {
        super.start()
        self.label?.text = "Synchronizing..."
    }
    
    override func stop() {
        super.stop()
        self.label?.text = "Synchronized"
    }
    
    private var notificationToken: NotificationToken?
    private var progressTokens: [SyncSession.ProgressNotificationToken]? {
        didSet {
            oldValue?.forEach({ $0.stop() })
        }
    }
    
    deinit {
        self.progressTokens = nil
        self.notificationToken?.stop()
    }
}
