//
//  EmojiPickerCollectionViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/3/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class EmojiPickerCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "EmojiPickerCollectionViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }
    
    @IBOutlet private weak var emojiLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.emojiLabel?.style_emojiDisplayLabel()
        self.prepareForReuse()
    }
    
    func configure(withEmojiString emojiString: String) {
        self.emojiLabel?.text = emojiString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.emojiLabel?.text = nil
    }

}
