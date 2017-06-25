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
    private var existingValue: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleItem?.title = "Reminder Interval"
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        self.completionHandler(self, nil)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        self.completionHandler(self, nil)
    }
}

extension ReminderIntervalPickerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return nil
    }
}

extension ReminderIntervalPickerViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
}
