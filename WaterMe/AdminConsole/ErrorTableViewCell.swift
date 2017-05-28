//
//  ErrorTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/28/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
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
