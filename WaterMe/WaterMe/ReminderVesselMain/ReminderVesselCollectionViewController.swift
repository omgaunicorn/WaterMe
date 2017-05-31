//
//  ReminderVesselCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/31/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import UIKit

class ReminderVesselCollectionViewController: UICollectionViewController, HasBasicController {
        
    var basicRC: BasicController? {
        didSet {
            self.hardReloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.register(ReminderVesselCollectionViewCell.nib, forCellWithReuseIdentifier: ReminderVesselCollectionViewCell.reuseID)
        log.debug("")
    }
    
    private func hardReloadData() {
        log.debug("")
    }
    
}
