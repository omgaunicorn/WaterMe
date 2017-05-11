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
    
    static let identifier = "SubscriptionChoiceCollectionViewCell"
    static let nib = UINib(nibName: SubscriptionChoiceCollectionViewCell.identifier, bundle: Bundle(for: SubscriptionChoiceCollectionViewCell.self))
    
    class func register(with collectionView: UICollectionView?) {
        collectionView?.register(self.nib, forCellWithReuseIdentifier: self.identifier)
    }
    
    class func newCell() -> SubscriptionChoiceCollectionViewCell {
        let cell = self.nib.instantiate(withOwner: nil, options: nil).first as! SubscriptionChoiceCollectionViewCell
        return cell
    }
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var priceLabel: UILabel?
    @IBOutlet private weak var button: UIButton?
    
    private let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        return nf
    }()
    
    var model: Subscription? {
        didSet {
            guard let model = self.model else { self.recycle(); return; }
            switch model.price {
            case .free:
                self.priceLabel?.text = "Free"
            case let .paid(price, locale):
                self.numberFormatter.locale = locale
                let priceString = self.numberFormatter.string(from: NSNumber(value: price))
                self.priceLabel?.text = priceString
            }
            self.titleLabel?.text = model.localizedTitle
            self.descriptionLabel?.text = model.localizedDescription
            
            self.button?.setTitle(model.level.callToAction, for: .normal)
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

fileprivate extension Subscription.Level {
    fileprivate var callToAction: String {
        switch self {
        case .free:
            return "Use WaterMe for Free"
        case .basic:
            return "Switch to Basic"
        case .pro:
            return "Go Pro"
        }
    }
}
