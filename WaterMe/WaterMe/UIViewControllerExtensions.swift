//
//  File.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

extension UIViewController {
    var topParent: UIViewController {
        
        var current: UIViewController? = self
        var next: UIViewController? = self
        
        while next != nil {
            current = next
            next = next?.parent
        }
        
        return current!
    }
}
