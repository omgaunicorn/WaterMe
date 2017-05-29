//
//  File.swift
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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

// Help for childVC's to find info from their parents or themselves easily
extension UIViewController {
    var topParent: UIViewController {
        var current: UIViewController?
        var next: UIViewController? = self
        while next != nil {
            current = next
            guard let nextParent = next?.parent, type(of: nextParent) != UINavigationController.self else { next = nil; continue; }
            next = nextParent
        }
        return current!
    }
}

// First Responder Methods for View Controllers
extension UIViewController {
    @objc private func dismiss(_ sender: NSObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

// Help for the RouterVC to dismiss and present things when there are already things presented
extension UIViewController {
    
    private var topPresentedVC: UIViewController? {
        var lastVC: UIViewController?
        var nextVC: UIViewController? = self.presentedViewController
        while nextVC != nil {
            lastVC = nextVC
            nextVC = nextVC?.presentedViewController
        }
        return lastVC
    }
    
    func dismissAllIfNeeded(animated: Bool, completion: (() -> Void)?) {
        if let lastVC = self.topPresentedVC {
            lastVC.dismiss(animated: animated, completion: { self.dismissAllIfNeeded(animated: animated, completion: completion) })
        } else {
            completion?()
        }
    }
    
    func presentOnTop(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let lastVC = self.topPresentedVC {
            lastVC.present(viewControllerToPresent, animated: animated, completion: completion)
        } else {
            self.present(viewControllerToPresent, animated: animated, completion: completion)
        }
    }
}
