//
//  EmailDeveloperViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/1/18.
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
import MessageUI
import UIKit

class EmailDeveloperViewController: MFMailComposeViewController, MFMailComposeViewControllerDelegate {

    typealias Completion = (UIViewController) -> Void

    class func newVC(completion: Completion?) -> Either<UIViewController, URL> {
        guard self.canSendMail() == true else { return .right(PrivateKeys.kEmailAddressURL) }
        let vc = EmailDeveloperViewController()
        vc.mailComposeDelegate = vc
        vc.setSubject("I have an idea for WaterMe!")
        vc.setToRecipients([PrivateKeys.kEmailAddress])
        vc.completion = completion
        return .left(vc)
    }

    private var completion: Completion?

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            break
        case .failed:
            break
        case .saved:
            break
        case .sent:
            break
        }
        self.completion?(self)
    }
}


