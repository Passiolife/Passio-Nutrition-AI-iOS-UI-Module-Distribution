//
//  CircularProgress.swift
//  Nutritaion-ai
//
//  Created by Mind on 12/02/24.
//

import UIKit

class DonutProgressView: UIView {

    var datasource: [Datasource] = []

    struct Datasource {
        var color: UIColor
        var percent: Double
    }

    private var radius: CGFloat { (bounds.height - lineWidth) / 2 }
    private let baseLayer = CAShapeLayer()
    private var progressLayers: [CALayer] = []

    @IBInspectable var lineWidth: CGFloat = 10 {
        didSet {
            self.baseLayer.lineWidth = lineWidth
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        baseLayer.fillColor = UIColor.clear.cgColor
        baseLayer.strokeColor = UIColor.clear.cgColor
        baseLayer.lineCap = .round
        baseLayer.strokeEnd = 1.0
        layer.addSublayer(baseLayer)
        self.backgroundColor = .clear
    }

    func updateData(data: [Datasource]) {

        let fraction = 0.23 // 0.17
        progressLayers.forEach { $0.removeFromSuperlayer() }
        let padding = CGFloat(data.filter({$0.percent > 0}).count) * fraction
        let totalRotationAngle = (CGFloat.pi * 2) - padding
        var startAngle = CGFloat.zero

        let total = data.reduce(0, {$0 + $1.percent})
        if total == 0 { return }

        for obj in data {
            if obj.percent > 0 {
                let layer = CAShapeLayer()
                let progressAngle = obj.percent / 100 * totalRotationAngle

                let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
                let path = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: startAngle,
                                        endAngle: startAngle + progressAngle,
                                        clockwise: true)
                layer.path = path.cgPath
                layer.strokeColor = obj.color.cgColor
                layer.fillColor = UIColor.clear.cgColor
                layer.lineWidth = self.lineWidth
                layer.lineCap = .round
                layer.strokeEnd = 1

                self.progressLayers.append(layer)
                self.layer.addSublayer(layer)

                startAngle += progressAngle + fraction
            }
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        baseLayer.frame = bounds
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let basePath = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: .initialAngle,
                                    endAngle: .endAngle(progress: 1),
                                    clockwise: true)
        baseLayer.path = basePath.cgPath
    }
}

public class CircleProgressView: UIView {

    var progress: CGFloat = 0.0 {
        didSet {
            if isWithAnimation {
                animateCircle(duration: 1, delay: 0)
            } else {
                setupProgress(progress: progress)
            }
        }
    }

    @IBInspectable var lineColor: UIColor? = .blue {
        didSet {
            guard let lineColor = lineColor else { return }
            self.baseLayer.strokeColor = lineColor.cgColor
        }
    }

    @IBInspectable var selectedLineColor: UIColor? = .blue {
        didSet {
            guard let selectedLineColor = selectedLineColor else { return }
            self.progressLayer.strokeColor = selectedLineColor.cgColor
        }
    }

    @IBInspectable var selectedDarkLineColor: UIColor? = .blue {
        didSet {
            guard let selectedDarkLineColor = selectedDarkLineColor else { return }
            upperProgressLayer.strokeColor = selectedDarkLineColor.cgColor
        }
    }

    @IBInspectable var isWithAnimation: Bool = false

    @IBInspectable var lineWidth: CGFloat = 10 {
        didSet {
            baseLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            upperProgressLayer.lineWidth = lineWidth
        }
    }

    private var radius: CGFloat { (bounds.height - lineWidth) / 2 }
    private let baseLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let upperProgressLayer = CAShapeLayer()

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        for layer in [baseLayer, progressLayer, upperProgressLayer] {
            layer.fillColor = UIColor.clear.cgColor
            layer.lineCap = .round
        }
        baseLayer.strokeEnd = 1.0

        layer.addSublayer(baseLayer)
        layer.addSublayer(progressLayer)
        layer.addSublayer(upperProgressLayer)
        backgroundColor = .clear

        if isWithAnimation {
            animateCircle(duration: 1, delay: 0)
        }
    }

    public func setupProgress(progress: CGFloat) {

        progressLayer.removeFromSuperlayer()
        upperProgressLayer.removeFromSuperlayer()

        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let progressPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: .initialAngle,
                                        endAngle: .endAngle(progress: progress),
                                        clockwise: true)
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeEnd = 1
        layer.addSublayer(progressLayer)

        if progress > 1 {
            let _progress = progress - 1
            let _progressPath = UIBezierPath(arcCenter: center,
                                             radius: radius,
                                             startAngle: .initialAngle,
                                             endAngle: .endAngle(progress: _progress),
                                             clockwise: true)
            upperProgressLayer.path = _progressPath.cgPath
            upperProgressLayer.strokeEnd = 1
            self.layer.addSublayer(upperProgressLayer)
        }
    }

    public func animateCircle(duration: TimeInterval, delay: TimeInterval) {

        self.progressLayer.removeFromSuperlayer()
        self.upperProgressLayer.removeFromSuperlayer()

        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let progressPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: .initialAngle,
                                        endAngle: .endAngle(progress: progress),
                                        clockwise: true)
        progressLayer.path = progressPath.cgPath
        self.layer.addSublayer(progressLayer)
        progressLayer.removeAnimation(forKey: "circleAnimation")
        progressLayer.strokeEnd = 1

        if progress > 1 {
            let _progress = progress - 1
            let _progressPath = UIBezierPath(arcCenter: center, 
                                             radius: radius,
                                             startAngle: .initialAngle,
                                             endAngle: .endAngle(progress: _progress),
                                             clockwise: true)
            upperProgressLayer.path = _progressPath.cgPath
            upperProgressLayer.strokeEnd = 1
            self.layer.addSublayer(upperProgressLayer)
            upperProgressLayer.removeAnimation(forKey: "circleAnimation")
        }

        addAnimation(duration: duration, delay: delay)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        baseLayer.frame = bounds
        progressLayer.frame = bounds
        upperProgressLayer.frame = bounds
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let basePath = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: .initialAngle,
                                    endAngle: .endAngle(progress: 1),
                                    clockwise: true)
        let progressPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: .initialAngle,
                                        endAngle: .endAngle(progress: progress),
                                        clockwise: true)
        baseLayer.path = basePath.cgPath
        progressLayer.path = progressPath.cgPath
        if progress > 1 {
            let _progress = progress - 1
            let _progressPath = UIBezierPath(arcCenter: center,
                                             radius: radius,
                                             startAngle: .initialAngle,
                                             endAngle: .endAngle(progress: _progress),
                                             clockwise: true)
            upperProgressLayer.path = _progressPath.cgPath
        }
    }
}

private extension CircleProgressView {

    func addAnimation(duration: TimeInterval, delay: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "circleAnimation")
        upperProgressLayer.add(animation , forKey: "circleAnimation")
    }
}

private extension CGFloat {

    static var initialAngle: CGFloat = -(.pi / 2)
    static func endAngle(progress: CGFloat) -> CGFloat {
        .pi * 2 * progress + .initialAngle
    }
}

class SpinnerView: UIView {

    let circlePathLayer = CAShapeLayer()

    func spin(color: UIColor, lineWidth: CGFloat) {
        circlePathLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        circlePathLayer.strokeColor = color.cgColor
        circlePathLayer.fillColor = nil
        circlePathLayer.lineWidth = lineWidth

        setPath(to: circlePathLayer)
        animate(layer: circlePathLayer)
        layer.addSublayer(circlePathLayer)
    }

    func stop(){
        layer.removeAllAnimations()
        circlePathLayer.removeFromSuperlayer()
    }

    private func setPath(to layer: CAShapeLayer) {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: layer.bounds.midX,
                                        y: layer.bounds.midY),
                    radius: (bounds.width / 2.0) - layer.lineWidth / 2,
                    startAngle: 0,
                    endAngle: 2 * .pi * 0.9,
                    clockwise: true)
        layer.path = path.cgPath
    }

    private func animate(layer: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 1
        animation.repeatCount = Float.infinity
        animation.fromValue = 0
        animation.toValue = 2 * CGFloat.pi
        layer.add(animation, forKey: "transform.rotation")
    }
}
