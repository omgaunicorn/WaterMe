//
//  SynchronizingViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/25/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
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
