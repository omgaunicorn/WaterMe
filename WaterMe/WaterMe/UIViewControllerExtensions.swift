//
//  File.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
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
