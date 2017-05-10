//
//  SubscriptionChoiceCollectionViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class SubscriptionChoiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var button: UIButton?
    
    var model: Subscription? {
        didSet {
            guard let model = self.model else { self.recycle(); return; }
            self.titleLabel?.text = model.localizedTitle
            self.descriptionLabel?.text = model.localizedDescription
            self.button?.setTitle("XXXX", for: .normal)
        }
    }
    
    private func recycle() {
        self.titleLabel?.text = nil
        self.descriptionLabel?.text = nil
        self.button?.setTitle(nil, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.recycle()
    }
    
}
