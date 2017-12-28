//
//  DragTargetInstructionalView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 28/12/17.
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

class DragTargetInstructionalView: UIView {

    @IBOutlet private weak var textLabel: UILabel?
    @IBOutlet private weak var circleButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.textLabel?.alpha = 0
        self.circleButton?.alpha = 0
        self.circleButton?.setTitle(nil, for: .normal)
        self.textLabel?.attributedText = NSAttributedString(string: "Drag and Drop Here", style: .dragInstructionalText)
    }

    func performInstructionalAnimation(completion: (() -> Void)?) {
        self.createCircleImage()
        UIView.animate(withDuration: 1, delay: 2, options: [], animations: {
            self.textLabel?.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 2, delay: 4, options: [], animations: {
                self.textLabel?.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: 1, animations: {
                    self.circleButton?.alpha = 1
                }, completion: { _ in
                    completion?()
                })
            })
        })
    }

    private func createCircleImage() {
        let stroke: CGFloat = 2
        let plusRadius: CGFloat = 10
        let bounds = self.circleButton?.bounds ?? .zero
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image() { _ in
            UIColor.black.setStroke()
            let circleRect = CGRect(x: bounds.origin.x + stroke / 2,
                                    y: bounds.origin.y + stroke / 2,
                                    width: bounds.width - stroke,
                                    height: bounds.height - stroke)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            let plusVerticalPath = UIBezierPath()
            plusVerticalPath.move(to: CGPoint(x: bounds.size.width / 2,
                                              y: (bounds.size.height / 2) - plusRadius))
            plusVerticalPath.addLine(to: CGPoint(x: bounds.size.width / 2,
                                                 y: (bounds.size.height / 2) + plusRadius))
            let plusHorizontalPath = UIBezierPath()
            plusHorizontalPath.move(to: CGPoint(x: (bounds.size.width / 2) - plusRadius,
                                              y: bounds.size.height / 2))
            plusHorizontalPath.addLine(to: CGPoint(x: (bounds.size.width / 2) + plusRadius,
                                                 y: bounds.size.height / 2))
            circlePath.lineWidth = stroke
            circlePath.stroke()
            plusVerticalPath.lineWidth = stroke
            plusVerticalPath.stroke()
            plusHorizontalPath.lineWidth = stroke
            plusHorizontalPath.stroke()
        }
        self.circleButton?.setImage(image, for: .normal)
        print("Created New Image: \(image)")
    }
}
