//
//  UITextField+Extension.swift
//  
//
//  Created by Nikunj Prajapati on 26/06/24.
//

import UIKit

extension UITextField {

    func applyTintColorOnClearButton(color: UIColor) {
        if let button = self.value(forKey: "clearButton") as? UIButton {
            button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = color
        }
    }

    func configureTextField(placeHolderText: String? = nil,
                            isAddImage: Bool = false,
                            leftPadding: CGFloat = 20,
                            radius: CGFloat = 10,
                            borderColor: UIColor = .gray200,
                            clearButtonColor: UIColor = .gray900) {
        if !isAddImage {
            leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: leftPadding, height: 0.0))
            leftViewMode = .always
        }

        textAlignment = .left
        attributedPlaceholder = NSAttributedString(string: placeHolderText ?? (placeholder ?? ""),
                                                   attributes: [.foregroundColor: UIColor.gray500])
        applyTintColorOnClearButton(color: clearButtonColor)
        applyBorder(width: 1, color: borderColor)
        roundMyCornerWith(radius: radius)
    }

    func addImageInTextField(isLeftImg: Bool, image: UIImage, imageFrame: CGRect) {
        let imageView = UIImageView(frame: imageFrame)
        imageView.image = image
        let imageContainerView = UIView(frame: CGRect(x: isLeftImg ? 5 : -4, y: 0, width: 34, height: 34))
        imageView.center = imageContainerView.center
        imageContainerView.addSubview(imageView)
        if isLeftImg {
            leftView = imageContainerView
            leftViewMode = .always
        } else {
            rightView = imageContainerView
            rightViewMode = .always
        }
    }

    func addOkButtonToToolbar(target: Any, action: Selector, forEvent: UIControl.Event) {
        let frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: 44)
        let kbToolBarView = UIToolbar.init(frame: frame)
        let okButton = UIButton()
        okButton.setTitle(Localized.Ok, for: .normal)
        okButton.titleLabel?.font = UIFont.inter(type: .medium, size: 14)
        okButton.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: 44)
        okButton.addTarget(target, action: action, for: forEvent)
        okButton.tag = self.tag
        let view = UIBarButtonItem.init(customView: okButton)
        kbToolBarView.items = [view]
        kbToolBarView.tintColor = .white
        kbToolBarView.barTintColor = .indigo600
        self.inputAccessoryView = kbToolBarView
    }

    func getText(replacing unit: String) -> String? {
        text?.replacingOccurrences(of: " \(unit)", with: "")
    }
}
