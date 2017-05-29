//
//  ErrorTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/28/17.
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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

class ErrorTableViewCell: UITableViewCell {
    
    static let reuseID = "ErrorTableViewCell"
    
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var fileLabel: UILabel?
    @IBOutlet private weak var functionLabel: UILabel?
    @IBOutlet private weak var lineLabel: UILabel?
    @IBOutlet private weak var dateLabel: UILabel?
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        return df
    }()
    
    func configure(with error: ConsoleError) {
        let localizedError = LocalizedError(rawValue: error.code)
        self.descriptionLabel?.text = localizedError.localizedDescription + "\n\n"
        self.fileLabel?.text = error.file
        self.lineLabel?.text = String(error.line)
        self.functionLabel?.text = error.function
        self.dateLabel?.text = self.dateFormatter.string(from: error.date)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.descriptionLabel?.text = nil
        self.fileLabel?.text = nil
        self.lineLabel?.text = nil
        self.functionLabel?.text = nil
        self.dateLabel?.text = nil
    }
    
}
