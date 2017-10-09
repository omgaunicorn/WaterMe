//
//  EmojiImageView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 7/31/17.
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

class EmojiImageView: UIView {
  
  init() {
    super.init(frame: .zero)
    self.initConfigure()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.initConfigure()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.initConfigure()
  }
  
  private func initConfigure() {
    let imageView = UIImageView()
    let label = UILabel()
    let views = [imageView, label]
    let stackView = UIStackView(arrangedSubviews: views)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    label.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(stackView)
    let constraints = [
      self.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0),
      self.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0),
      self.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0),
      self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0)
    ]
    self.addConstraints(constraints)
    label.isHidden = true
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    let maskLayer = CAShapeLayer()
    imageView.layer.mask = maskLayer
    stackView.distribution = .fill
    stackView.alignment = .center
    stackView.axis = .vertical
    self.imageViewMaskLayer = maskLayer
    self.imageView = imageView
    self.label = label
    self.backgroundColor = .clear
  }
  
  enum Size {
    case small, large
    func attributedString(with string: String) -> NSAttributedString {
      let accessibility = UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
      switch self {
      case .small:
        let style = Style.emojiSmall(accessibilityFontSizeEnabled: accessibility)
        return NSAttributedString(string: string, style: style)
      case .large:
        let style = Style.emojiLarge(accessibilityFontSizeEnabled: accessibility)
        return NSAttributedString(string: string, style: style)
      }
    }
  }
  
  var size: Size = .large

  private weak var imageView: UIImageView?
  private weak var label: UILabel?
  private weak var imageViewMaskLayer: CAShapeLayer?
  
  func setIcon(_ icon: ReminderVessel.Icon?, for controlState: UIControlState = .normal) {
    guard let icon = icon else {
      self.alpha = 0.4
      self.label?.attributedText = self.size.attributedString(with: "🌸")
      self.label?.isHidden = false
      self.imageView?.image = nil
      self.imageView?.isHidden = true
      return
    }
    
    self.alpha = 1.0
    switch icon {
    case .emoji(let string):
      self.imageView?.image = nil
      self.imageView?.isHidden = true
      self.label?.attributedText = self.size.attributedString(with: string)
      self.label?.isHidden = false
    case .image(let image):
      self.imageView?.image = image
      self.imageView?.isHidden = false
      self.label?.attributedText = nil
      self.label?.isHidden = true
    }
  }
  
  func setKind(_ kind: Reminder.Kind?, for controlState: UIControlState = .normal) {
    guard let kind = kind else {
      self.alpha = 0.4
      self.label?.attributedText = self.size.attributedString(with: "🌸")
      self.label?.isHidden = false
      self.imageView?.image = nil
      self.imageView?.isHidden = true
      return
    }
    
    let string: NSAttributedString
    switch kind {
    case .water:
      string = self.size.attributedString(with: "💦")
    case .fertilize:
      string = self.size.attributedString(with: "🎩")
    case .move:
      string = self.size.attributedString(with: "🔄")
    case .other:
      string = self.size.attributedString(with: "❓")
    }
    self.label?.attributedText = string
    self.alpha = 1.0
    self.label?.isHidden = false
    self.imageView?.isHidden = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let bounds = self.bounds
    let cornerRadius = floor(bounds.size.width / 2)
    self.imageViewMaskLayer?.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    switch self.size {
    case .small:
      self.layer.borderWidth = 0
      self.layer.borderColor = nil
      self.layer.cornerRadius = 0
    case .large:
      self.layer.borderWidth = 2
      self.layer.borderColor = self.tintColor.cgColor
      self.layer.cornerRadius = cornerRadius
    }
  }
}
