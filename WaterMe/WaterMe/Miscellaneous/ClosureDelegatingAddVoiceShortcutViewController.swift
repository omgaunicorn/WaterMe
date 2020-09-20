//
//  ClosureDelegatingAddVoiceShortcutViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/26/18.
//  Copyright © 2018 Saturday Apps.
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

import IntentsUI
import Calculate

@available(iOS 12.0, *)
class ClosureDelegatingAddVoiceShortcutViewController: INUIAddVoiceShortcutViewController, INUIAddVoiceShortcutViewControllerDelegate {

    enum Result {
        case success(INVoiceShortcut), cancel, failure(UserActivityError)
    }

    var completionHandler: ((UIViewController, Result) -> Void)?

    override init(shortcut: INShortcut) {
        super.init(shortcut: shortcut)
        self.presentationController?.delegate = self
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.presentationController?.delegate = self
        self.delegate = self
    }

    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController,
                                        didFinishWith voiceShortcut: INVoiceShortcut?,
                                        error: Error?)
    {
        if let error = error {
            error.log()
            self.completionHandler?(self, .failure(.createShortcutFailed))
        } else if let shortcut = voiceShortcut {
            self.completionHandler?(self, .success(shortcut))
        } else {
            assertionFailure("Invalid Callback from IntentsUI API")
            self.completionHandler?(self, .cancel)
        }
    }
    public func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        self.completionHandler?(self, .cancel)
    }
}

@available(iOS 12.0, *)
extension ClosureDelegatingAddVoiceShortcutViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.completionHandler?(self, .cancel)
    }
}
