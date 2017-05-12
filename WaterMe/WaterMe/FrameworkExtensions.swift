//
//  FrameworkExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

extension Sequence {
    func first<T>(of type: T.Type? = nil) -> T? {
        return self.first(where: { $0 is T }) as? T
    }
}

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        let indexPaths = self.indexPathsForSelectedItems
        indexPaths?.forEach({ self.deselectItem(at: $0, animated: animated) })
    }
}
