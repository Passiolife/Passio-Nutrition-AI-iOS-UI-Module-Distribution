//
//  MacroProgressBarChartView.swift
//  BaseApp
//
//  Created by Mind on 01/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class MacroProgressBarChartView: ViewFromXIB {
    @IBOutlet weak var shadowView : UIView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var chartView  : CustomBarChartView!
    
    @IBOutlet weak var range1Label: UILabel!
    @IBOutlet weak var range2Label: UILabel!
    @IBOutlet weak var range3Label: UILabel!
    
    @IBOutlet weak var xAxisStackView: UIStackView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    var title: String = ""{
        didSet {
            self.titleLabel.text = title
        }
    }
    
    func setupChart(datasource: [ChartDataSource],
                    baseLine: CGFloat? = nil,
                    maximum: CGFloat,
                    dates: [Date]) {
        chartView.gridLineColor = .gray200
        chartView.barWidth = datasource.count <= 7 ? 12 : 6
        self.chartView.setupbarChart(dataSource: datasource,baseLine: baseLine, maximum: maximum)
        self.setupYAxisLabel(maximum: Double(maximum))
        self.setupXAxisLabel(dates: dates)
    }
    
    func setupLineChart(datasource: [ChartDataSource],
                        baseLine: CGFloat? = nil,
                        maximum: CGFloat,
                        dates: [Date]) {
        chartView.gridLineColor = .gray200
        self.chartView.setupLineChart(dataSource: datasource,baseLine: baseLine, maximum: maximum,dotSize: 4,lineWidth: 2)
        self.setupYAxisLabel(maximum: Double(maximum))
        self.setupXAxisLabel(dates: dates)
    }
    
    
    func setupChart(datasource: [CombineChartDataSource],
                    baseLine: CGFloat? = nil,
                    maximum: CGFloat,
                    dates: [Date]){
        chartView.gridLineColor = .gray200
        chartView.barWidth = datasource.count <= 7 ? 12 : 6
        self.chartView.setupCombinedBarChart(dataSource: datasource,baseLine: baseLine, maximum: maximum)
        self.setupYAxisLabel(maximum: Double(maximum))
        self.setupXAxisLabel(dates: dates)
    }
    
    private func setupYAxisLabel(maximum: Double) {
        self.range1Label.text = 0.clean
        self.range2Label.text = (maximum / 2).rounded().clean
        self.range3Label.text = (maximum).rounded().clean
    }
    
    
    private func setupXAxisLabel(dates: [Date]) {
        xAxisStackView.subviews.forEach({$0.removeFromSuperview()})
        if dates.count == 7 {
            for date in dates {
                let dateFormattor = DateFormatter()
                dateFormattor.dateFormat = "EE"
                let dateString = dateFormattor.string(from: date)
                xAxisStackView.addArrangedSubview(getLabel(text: dateString))
            }
            xAxisStackView.distribution = .fillEqually
        }else if dates.count > 7{
            let dateIndex2 = dates.count / 3
            let dateIndex3 = 2 * dates.count / 3
            let _dates = [dates.first!,dates[dateIndex2],dates[dateIndex3],dates.last!]
            for date in _dates {
                let dateFormattor = DateFormatter()
                dateFormattor.dateFormat = "MMM d"
                let dateString = dateFormattor.string(from: date)
                xAxisStackView.addArrangedSubview(getLabel(text: dateString))
            }
            xAxisStackView.distribution = .equalSpacing
        }
    }
    
    private func getLabel(text: String)  -> UILabel{
        let label = UILabel()
        label.text = text
        label.font = UIFont.inter(type: .regular, size: 12)
        label.textColor = .gray900
        label.textAlignment = .center
        return label
    }
}

extension CALayer {
    func applyCornerRadiusShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0,
        cornerRadiusValue: CGFloat = 8)
    {
        cornerRadius = cornerRadiusValue
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
