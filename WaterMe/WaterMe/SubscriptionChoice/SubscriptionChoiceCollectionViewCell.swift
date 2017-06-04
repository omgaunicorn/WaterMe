//
//  SubscriptionChoiceCollectionViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
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

import WaterMeStore
import UIKit

class SubscriptionChoiceCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SubscriptionChoiceCollectionViewCell"
    static let nib = UINib(nibName: SubscriptionChoiceCollectionViewCell.identifier, bundle: Bundle(for: SubscriptionChoiceCollectionViewCell.self))
    
    class func register(with collectionView: UICollectionView?) {
        collectionView?.register(self.nib, forCellWithReuseIdentifier: self.identifier)
    }
    
    class func newCell() -> SubscriptionChoiceCollectionViewCell {
        // swiftlint:disable:next force_cast
        let cell = self.nib.instantiate(withOwner: nil, options: nil).first as! SubscriptionChoiceCollectionViewCell
        return cell
    }
    
    @IBOutlet private(set) var widthConstraint: NSLayoutConstraint?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var priceLabel: UILabel?
    
    private let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        return nf
    }()
    
    var model: UnpurchasedSubscription? {
        didSet {
            guard let model = self.model else { self.recycle(); return; }
            self.numberFormatter.locale = model.priceLocale
            let priceString = self.numberFormatter.string(from: NSNumber(value: model.price)) ?? ""
            self.priceLabel?.text = priceString + " " + model.period.localizedString
            self.titleLabel?.text = model.localizedTitle
            self.descriptionLabel?.text = model.localizedDescription
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.widthConstraint?.isActive = false
        self.recycle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.recycle()
    }
    
    private func recycle() {
        self.titleLabel?.text = nil
        self.priceLabel?.text = nil
        self.descriptionLabel?.text = nil
    }
    
}

fileprivate extension Period {
    fileprivate var localizedString: String {
        switch self {
        case .month:
            return "per Month"
        case .year:
            return "per Year"
        }
    }
}
