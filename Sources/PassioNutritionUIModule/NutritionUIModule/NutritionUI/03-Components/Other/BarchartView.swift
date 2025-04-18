//
//  BarchartView.swift
//  BaseApp
//
//  Created by Mind on 29/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit

struct ChartDataSource {
    var value: CGFloat?
    var color: UIColor
}

struct CombineChartDataSource {
    var dataSource: [ChartDataSource]
}

class CustomBarChartView: UIView {

    private var lineLayers: [CAShapeLayer] = []
    private var barLayers: [CAShapeLayer] = []

    var barWidth: CGFloat = 12
    var numberOfGrids: Int = 3
    var gridLineColor: UIColor = .gray
    var animateGraph: Bool = false

    func setupbarChart(dataSource: [ChartDataSource],
                       baseLine: CGFloat? = nil,
                       maximum: CGFloat) {

        self.layoutIfNeeded()
        self.drawGrid(gridCount: self.numberOfGrids)
        if let baseLine = baseLine {
            self.drawBaseline(value: baseLine, max: maximum)
        }
        barLayers.forEach({$0.removeFromSuperlayer()})

        let totalHeight = self.bounds.height
        let widthWithPadding = self.bounds.width / CGFloat(dataSource.count)
        let heightRatio = totalHeight / maximum

        for i in 0..<dataSource.count {
            let index = CGFloat(i)

            let centerX = ((index + 0.5) * widthWithPadding)// - (barWidth * 0.5)
            let y = self.bounds.height
            let barHeight = heightRatio * (dataSource[i].value ?? 0)
            let startPoint = CGPoint(x: centerX, y: y)
            let endPoint = CGPoint(x: centerX, y: y - barHeight)

            if let layer = drawLine(points: [startPoint,endPoint],
                                    strokeColor: dataSource[i].color,
                                    linewidth: self.barWidth,
                                    animate: animateGraph) {
                self.layer.addSublayer(layer)
                self.barLayers.append(layer)
            }
        }
    }

    func setupLineChart(dataSource: [ChartDataSource],
                        baseLine: CGFloat? = nil,
                        maximum: CGFloat,
                        dotSize: CGFloat = 4,
                        lineWidth: CGFloat = 2) {

        self.layoutIfNeeded()
        self.drawGrid(gridCount: self.numberOfGrids)
        if let baseLine = baseLine {
            self.drawBaseline(value: baseLine, max: maximum)
        }
        barLayers.forEach({$0.removeFromSuperlayer()})

        let totalHeight = self.bounds.height
        let widthWithPadding = self.bounds.width / CGFloat(dataSource.count)
        let heightRatio = totalHeight / maximum

        var points: [CGPoint] = []

        for i in 0..<dataSource.count {
            if let value = dataSource[i].value {

                let index = CGFloat(i)

                let dotX = ((index + 0.5) * widthWithPadding)// - (barWidth * 0.5)
                let dotY = self.bounds.height - (heightRatio * value)
                let point = CGPoint(x: dotX, y: dotY)
                points.append(point)

                if let dot = drawDot(points: point,
                                     strokeColor: dataSource[i].color,
                                     radius: dotSize) {
                    self.layer.addSublayer(dot)
                    self.barLayers.append(dot)
                }
            }
        }

        if let layer = drawLine(points: points,
                                strokeColor: dataSource.first?.color ?? .blue,
                                linewidth: lineWidth,
                                animate: animateGraph) {
            self.layer.addSublayer(layer)
            self.barLayers.append(layer)
        }
    }

    func setupCombinedBarChart(dataSource: [CombineChartDataSource],
                               baseLine: CGFloat? = nil,
                               maximum: CGFloat) {
        self.layoutIfNeeded()
        self.drawGrid(gridCount: self.numberOfGrids)
        if let baseLine = baseLine {
            self.drawBaseline(value: baseLine, max: maximum)
        }
        barLayers.forEach({$0.removeFromSuperlayer()})

        let totalHeight = self.bounds.height
        let widthWithPadding = self.bounds.width / CGFloat(dataSource.count)
        let heightRatio = totalHeight / maximum

        for i in 0..<dataSource.count{
            let index = CGFloat(i)

            let centerX = ((index + 0.5) * widthWithPadding)// - (barWidth * 0.5)
            var y = self.bounds.height

            for j in 0..<dataSource[i].dataSource.count{
                let obj = dataSource[i].dataSource[j]
                let barHeight = heightRatio * (obj.value ?? 0)
                let startPoint = CGPoint(x: centerX, y: y)
                let endPoint = CGPoint(x: centerX, y: y - barHeight)
                if let layer = drawLine(points: [startPoint,endPoint],
                                        strokeColor: obj.color,
                                        linewidth: self.barWidth) {
                    self.layer.addSublayer(layer)
                    self.barLayers.append(layer)
                }
                y -= barHeight
            }
        }
    }

    // MARK: - Drawing Grid Lines
    private func drawGrid(gridCount: Int) {

        lineLayers.forEach({ $0.removeFromSuperlayer()} )

        let totalHeight = self.bounds.height
        let heightRatio = totalHeight / CGFloat (gridCount - 1)
        let startX: CGFloat = 0
        let endX  : CGFloat = self.bounds.width

        for i in 0..<gridCount {
            let index = CGFloat(i)

            let y = self.bounds.height - (index * heightRatio)
            let startPoint = CGPoint(x: startX, y: y)
            let endPoint = CGPoint(x: endX, y: y)

            if let layer = drawLine(points: [startPoint,endPoint],
                                    strokeColor: self.gridLineColor,
                                    linewidth: 1) {
                self.layer.addSublayer(layer)
                self.lineLayers.append(layer)
            }
        }
    }

    private func drawBaseline(value: CGFloat, max: CGFloat) {

        let totalHeight = self.bounds.height
        let startX: CGFloat = 0
        let endX  : CGFloat = self.bounds.width

        let y = totalHeight - ((totalHeight * value) / max)

        let startPoint = CGPoint(x: startX, y: y)
        let endPoint = CGPoint(x: endX, y: y)

        if let layer = drawDashedLine(points: [startPoint,endPoint], strokeColor: .green500, linewidth: 2) {
            self.layer.addSublayer(layer)
            self.lineLayers.append(layer)
        }
    }

    // MARK: - Drawing Methods
    private func pathFrom(points: [CGPoint]) -> UIBezierPath?{
        guard points.count > 0 else {return nil}
        let path = UIBezierPath()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }

    private func drawLine(points: [CGPoint], strokeColor: UIColor, linewidth: CGFloat, animate: Bool = false) -> CAShapeLayer?{
        guard let path = pathFrom(points: points) else { return nil }
        return drawALayer(path, strokeColor, .clear ,linewidth, animate)
    }

    private func drawDot(points: CGPoint,strokeColor: UIColor, radius: CGFloat = 3) -> CAShapeLayer? {
        let path = UIBezierPath(arcCenter: points,
                                radius: radius - 1,
                                startAngle: 0,
                                endAngle: 2 * .pi,
                                clockwise: true)
        return drawALayer(path, strokeColor, strokeColor ,1)
    }

    private func drawALayer(_ path: UIBezierPath,
                            _ strokeColor: UIColor,
                            _ fillColor: UIColor,
                            _ linewidth: CGFloat,
                            _ animate: Bool = false) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineWidth = linewidth
        layer.strokeEnd = 1
        if animate {
            // Animate the drawing of the circle (path animation)
            let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
            drawAnimation.fromValue = 0
            drawAnimation.toValue = 1
            drawAnimation.duration = 0.8 // Duration of the animation
            drawAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Add the animation to the shape layer
            layer.add(drawAnimation, forKey: "drawCircleAnimation")
        }
        return layer
    }

    private func drawDashedLine(points: [CGPoint],
                                strokeColor: UIColor,
                                linewidth: CGFloat,
                                dashedPattern: [NSNumber] = [7,7]) -> CAShapeLayer? {
        guard let path = pathFrom(points: points) else { return nil }
        let layer = drawALayer(path, strokeColor, .clear ,linewidth)
        layer.lineDashPattern = dashedPattern
        return layer
    }
}
