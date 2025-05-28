//
//  Untitled.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 23/05/25.
//

import UIKit

let tfBorderColor = UIColor.rgb(200, 202, 208)
let tfInvalidBorderColor = UIColor.rgb(255, 24, 24) //UIColor.rgb(255, 84, 84)
let tfBorderWidth: CGFloat = 1
let tfCornerRadius: CGFloat = 8

extension UITextField {
    func setValid(_ isValid: Bool) {
        if isValid {
            layer.borderColor = tfBorderColor.cgColor
        } else {
            layer.borderColor = tfInvalidBorderColor.cgColor
        }
    }
}

@IBDesignable
class PassioTF: UITextField {
    
    @IBInspectable
    var horizontalPadding: CGFloat = 8
    var textImagePadding: CGFloat = 0

    // MARK: - Right Image Support
    @IBInspectable
    var rightImage: UIImage? {
        didSet {
            setRightImage()
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Common Setup
    private func commonInit() {
        borderStyle = .none
        textColor = .black
        layer.cornerRadius = tfCornerRadius
        layer.borderColor = tfBorderColor.cgColor
        layer.borderWidth = tfBorderWidth
    }
    
    // MARK: - Text Position Adjustments
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedTextRect(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedTextRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedTextRect(forBounds: bounds)
    }
    
    private func adjustedTextRect(forBounds bounds: CGRect) -> CGRect {
        let rightViewWidth = rightView?.frame.width ?? 0
        
        var rightInset: CGFloat = 0
        if rightViewWidth > 0 {
            rightInset = textImagePadding + rightViewWidth + horizontalPadding
        } else {
            rightInset = horizontalPadding
        }
        return bounds.inset(by: UIEdgeInsets(top: 0, left: horizontalPadding, bottom: 0, right: rightInset))
    }
    
    // MARK: - Right View Position
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= horizontalPadding
        return rect
    }
    
    // MARK: - Right Image Setup
    private func setRightImage() {
        if let image = rightImage {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
            rightView = imageView
            rightViewMode = .always
        } else {
            rightView = nil
            rightViewMode = .never
        }
        setNeedsLayout()
    }
}
