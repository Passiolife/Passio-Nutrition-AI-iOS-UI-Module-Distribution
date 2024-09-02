//
//  UIButton+Extension.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 27/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

extension UIButton {

    func underline() {
        guard let text = titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineColor,
                                      value: titleColor(for: .normal)!,
                                      range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: titleColor(for: .normal)!,
                                      range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: text.count))
        setAttributedTitle(attributedString, for: .normal)
    }

    public func enableDisableButton(with animation: UIView.AnimationOptions = .transitionCrossDissolve,
                                    duration: TimeInterval = 0.3,
                                    opacity: CGFloat = 0.8,
                                    isEnabled: Bool) {
        alpha = isEnabled ? opacity : 1
        self.isEnabled = isEnabled
        UIView.animate(withDuration: duration, delay: 0, options: animation) {
            self.alpha = self.isEnabled ? 1 : opacity
        }
    }

    func showImagePickerMenu(cameraAction: @escaping UIActionHandler,
                             photosAction: @escaping UIActionHandler) {
        let camera = UIAction(title: "Camera",
                              image: UIImage(systemName: "camera"),
                              handler: cameraAction)
        let photos = UIAction(title: "Photos",
                              image: UIImage(systemName: "photo"),
                              handler: photosAction)
        menu = UIMenu(title: "", children: [camera, photos])
        showsMenuAsPrimaryAction = true
    }
}
