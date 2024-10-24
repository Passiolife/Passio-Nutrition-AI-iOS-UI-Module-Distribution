//
//  UIView.swift
//  PassioPassport
//
//  Created by Former Developer on 6/3/18.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit

public extension UIView {

    private static let kRotationAnimationKey = "rotationanimationkey"

    // MARK: @IBInspectable
    @IBInspectable var vwCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var vwBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var vwBorderColor: UIColor? {
        get {
            guard let borderColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var isRoundedCorner: Bool {
        get {
            return self.isRoundedCorner
        }
        set {
            if newValue {
                roundMyCorner()
            }
        }
    }

    // MARK: Helper
    func roundMyCorner() {
        let radius = min(self.bounds.height, self.bounds.width)/2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func roundMyCornerWith(radius: CGFloat) {
        self.layer.cornerRadius = 0
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func roundMyCornerWith(radius: CGFloat, upper: Bool, down: Bool) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.maskedCorners = []
        if upper {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if down {
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        self.clipsToBounds = true
    }

    func fadeIn(seconds: Double,
                animationType: UIView.KeyframeAnimationOptions = .calculationModeLinear) {
        self.alpha = 0
        UIView.animateKeyframes(withDuration: seconds,
                                delay: 0,
                                options: animationType,
                                animations: {
            self.alpha = 1
        })
    }

    func fadeOut(seconds: Double,
                 delay: Double = 0,
                 animationType: UIView.KeyframeAnimationOptions = .calculationModeLinear) {
        self.alpha = 1
        UIView.animateKeyframes(withDuration: seconds,
                                delay: delay,
                                options: animationType,
                                animations: {
            self.alpha = 0
        })
    }

    func findViewController() -> UIViewController? {
        if let nexrResponder = self.next as? UIViewController {
            return nexrResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }

    func startRotating(duration: Double = 1) {
        guard layer.animation(forKey: UIView.kRotationAnimationKey) == nil else { return }
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0.0
        rotation.toValue = Float.pi * 2.0
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = Float.infinity
        self.layer.add(rotation, forKey: UIView.kRotationAnimationKey)
    }

    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }

    class func fromNib(named: String? = nil, bundle: Bundle = .main) -> Self {
        let name = named ?? "\(Self.self)"
        guard
            let nib =  bundle.loadNibNamed(name, owner: nil, options: nil)
        else { fatalError("missing expected nib named: \(name)") }
        guard
            /// we're using `first` here because compact map chokes compiler on
            /// optimized release, so you can't use two views in one nib if you wanted to
            /// and are now looking at this
            let view = nib.first as? Self
        else { fatalError("view of type \(Self.self) not found in \(nib)") }
        return view
    }

    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }

    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }

    func applyBorder(width: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    /// Use this function to draw shadow
    /// - Parameters:
    ///   - radius: View's cornerRadius
    ///   - offset: Shadow's offset
    ///   - color: Shadow's color
    ///   - shadowRadius: Shadow's radius (blur)
    ///   - shadowOpacity: Shadow's opacity
    func dropShadow(radius: CGFloat,
                    offset: CGSize,
                    color: UIColor,
                    shadowRadius: CGFloat,
                    shadowOpacity: Float,
                    istopBottomRadius: Bool = false,
                    isUpperRadius: Bool = false,
                    isDownRadius: Bool = false) {

        if istopBottomRadius {
            roundMyCornerWith(radius: radius, upper: isUpperRadius, down: isDownRadius)
        } else {
            layer.cornerRadius = radius
        }

        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if image != nil {
            return image!
        }
        return UIImage()
    }

    func blinkMe(withDuration: Double = 0.6) {
        UIView.animate(withDuration: withDuration,
                       delay: 0.0,
                       options: [.autoreverse, .repeat], animations: {
            self.alpha = 0.1
        }, completion: nil)
    }

    func showHideView(with animation: UIView.AnimationOptions = .transitionCrossDissolve,
                      duration: TimeInterval = 0.3,
                      isHidden: Bool) {
        alpha = isHidden ? 1 : 0
        self.isHidden = isHidden
        UIView.animate(withDuration: duration, delay: 0, options: animation) {
            self.alpha = self.isHidden ? 0 : 1
        }
    }

    func animateBackgroundColor(color: UIColor,
                                duration: TimeInterval = 0.3) {
        UIView.transition(with: self,
                          duration: 0.21,
                          options: .curveEaseInOut,
                          animations: {
            self.backgroundColor = color
        })
    }

    func fitToSelf(childView: UIView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["childView": childView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat : "H:|[childView]|",
                                                      options : [],
                                                      metrics : nil,
                                                      views : bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat : "V:|[childView]|",
                                                      options : [],
                                                      metrics : nil,
                                                      views : bindings))
    }

    func addConstraints(to view: UIView,
                        attribute: NSLayoutConstraint.Attribute,
                        constant: CGFloat) {
        addConstraint(NSLayoutConstraint(item: view,
                                         attribute: attribute,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: attribute,
                                         multiplier: 1,
                                         constant: constant))
    }

    func configureSearchBarTextField(tintColor: UIColor = .primaryColor,
                                     textAttr: [NSAttributedString.Key : Any] = [
                                        .foregroundColor: UIColor.gray900,
                                        .font: UIFont.inter(type: .regular, size: 16)
                                     ]) {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = tintColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = textAttr
    }
}

class PassThroughView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point,
                                                                                                      to: subview),
                                                                                      with: event) {
                return true
            }
        }
        return false
    }
}

extension CALayer {
    class func performWithoutAnimation(_ callback: () -> Void) {
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        callback()
        CATransaction.commit()
    }
}
