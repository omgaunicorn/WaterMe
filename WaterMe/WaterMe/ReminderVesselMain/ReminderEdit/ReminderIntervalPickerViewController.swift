//
//  ReminderIntervalPickerViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/24/17.
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

import WaterMeData
import UIKit

class ReminderIntervalPickerViewController: UIViewController {
    
    typealias CompletionHandler = (UIViewController, Int?) -> Void
    
    class func newVC(from storyboard: UIStoryboard!, existingValue: Int, completionHandler: @escaping CompletionHandler) -> UIViewController {
        let id = "ReminderIntervalPickerViewController"
        // swiftlint:disable:next force_cast
        let vc = storyboard.instantiateViewController(withIdentifier: id) as! ReminderIntervalPickerViewController
        vc.completionHandler = completionHandler
        vc.existingValue = existingValue
        return vc
    }
    
    @IBOutlet private weak var pickerView: UIPickerView?
    @IBOutlet private weak var titleItem: UINavigationItem?
    
    private var completionHandler: CompletionHandler!
    private var existingValue: Int = Reminder.defaultInterval
    
    fileprivate lazy var primaryFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
    fileprivate let data: [Int] = (Reminder.minimumInterval...Reminder.maximumInterval).map({ $0 })
    fileprivate let formatter = DateComponentsFormatter.newReminderIntervalFormatter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleItem?.title = "Reminder Interval"
        
        let existingIndex = self.data.index(of: self.existingValue) ?? 0
        self.pickerView?.selectRow(existingIndex, inComponent: 0, animated: false)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        self.completionHandler(self, nil)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        let selectedIndex = self.pickerView?.selectedRow(inComponent: 0) ?? 0
        let selectedItem = self.data[selectedIndex]
        self.completionHandler(self, selectedItem)
    }
}

extension ReminderIntervalPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let days = self.data[row]
        let interval: TimeInterval = TimeInterval(days) * (24 * 60 * 60)
        let formattedString = self.formatter.string(from: interval) ?? "–"
        let primary: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : self.primaryFont,
            NSAttributedStringKey.foregroundColor : UIColor.black
        ]
        let string = NSAttributedString(string: formattedString, attributes: primary)
        return string
    }
}

extension ReminderIntervalPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
    }
}
