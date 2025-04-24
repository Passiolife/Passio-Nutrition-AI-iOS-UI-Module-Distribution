//
//  File.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 23/04/25.
//

import UIKit

@IBDesignable
class CircularSpinner: UIView {
    
    private let shapeLayer = CAShapeLayer()
    
    @IBInspectable var color: UIColor = .systemBlue {
        didSet {
            shapeLayer.strokeColor = color.cgColor
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 3.0 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.addSublayer(shapeLayer)
        animate()
    }
    
    private func animate() {
        shapeLayer.removeAllAnimations()
        
        let width = frame.size.width
        let height = frame.size.height
        let center = CGPoint(x: width / 2, y: height / 2)
        
        let beginTime = 0.5
        let durationStart = 1.15 // 1.2
        let durationStop = 0.75 // 0.7
        
        let animationRotation = CABasicAnimation(keyPath: "transform.rotation")
        animationRotation.byValue = 2 * CGFloat.pi
        animationRotation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let animationStart = CABasicAnimation(keyPath: "strokeStart")
        animationStart.duration = durationStart
        animationStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
        animationStart.fromValue = 0
        animationStart.toValue = 1
        animationStart.beginTime = beginTime
        
        let animationStop = CABasicAnimation(keyPath: "strokeEnd")
        animationStop.duration = durationStop
        animationStop.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
        animationStop.fromValue = 0
        animationStop.toValue = 1
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animationRotation, animationStop, animationStart]
        animationGroup.duration = durationStart + beginTime
        animationGroup.repeatCount = .infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        
        let path = UIBezierPath(arcCenter: center,
                                radius: (min(width, height) - lineWidth) / 2,
                                startAngle: -.pi / 2,
                                endAngle: 1.5 * .pi,
                                clockwise: true)
        
        shapeLayer.frame = bounds
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.add(animationGroup, forKey: "spinnerAnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        animate()
    }
}
