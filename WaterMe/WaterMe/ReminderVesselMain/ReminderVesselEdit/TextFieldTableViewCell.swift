//
//  TextFieldTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/2/17.
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

class TextFieldTableViewCell: UITableViewCell {
    
    static let reuseID = "TextFieldTableViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }
    
    @IBOutlet private weak var textField: UITextField?
    @IBOutlet private weak var label: UILabel?
    
    var textChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField?.style_bodyFontTextField()
        self.label?.style_calloutFontLabel()
        self.prepareForReuse()
    }
    
    func setTextField(text: String?) {
        self.textField?.text = text ?? ""
    }
    
    func setPlaceHolder(label: String?, textField: String?) {
        self.textField?.placeholder = textField ?? ""
        if let label = label {
            self.label?.isHidden = false
            self.label?.text = label
        } else {
            self.label?.isHidden = true
            self.label?.text = ""
        }
    }
    
    @IBAction private func textChanged(_ sender: Any) {
        let newValue = self.textField?.text ?? ""
        self.textChanged?(newValue)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.textField?.text = nil
        self.textField?.placeholder = nil
        self.label?.text = nil
        self.textChanged = nil
        self.label?.isHighlighted = true
        
    }
}
