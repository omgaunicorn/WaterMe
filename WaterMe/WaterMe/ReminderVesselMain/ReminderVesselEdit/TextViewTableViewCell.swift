//
//  TextViewTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 7/5/17.
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

import UIKit

class TextViewTableViewCell: UITableViewCell, UITextViewDelegate {
    
    static let reuseID = "TextViewTableViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }
    
    @IBOutlet private weak var textView: UITextView?
    
    var textChanged: ((String) -> Void)?
    
    func configure(with text: String) {
        self.textView?.text = text
        self.textView?.scrollRectToVisible(.zero, animated: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView?.style_tableViewCellTextInput()
        self.textView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        self.prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.textView?.text = nil
    }
    
    func textViewDidChange(_ textView: UITextView) {
        assert(textView === self.textView, "Something is wrong with the textviews")
        let newText = self.textView?.text ?? ""
        self.textChanged?(newText)
    }
    
}
