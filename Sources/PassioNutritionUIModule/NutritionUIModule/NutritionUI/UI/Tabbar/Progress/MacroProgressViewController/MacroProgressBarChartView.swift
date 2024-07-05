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

    var title: String = "" {
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
        chartView.setupbarChart(dataSource: datasource,
                                baseLine: baseLine,
                                maximum: maximum)
        setupYAxisLabel(maximum: Double(maximum))
        setupXAxisLabel(dates: dates)
    }

    func setupLineChart(datasource: [ChartDataSource],
                        baseLine: CGFloat? = nil,
                        maximum: CGFloat,
                        dates: [Date]) {
        chartView.gridLineColor = .gray200
        chartView.setupLineChart(dataSource: datasource,
                                      baseLine: baseLine,
                                      maximum: maximum,
                                      dotSize: 4,
                                      lineWidth: 2)
        setupYAxisLabel(maximum: Double(maximum))
        setupXAxisLabel(dates: dates)
    }

    func setupChart(datasource: [CombineChartDataSource],
                    baseLine: CGFloat? = nil,
                    maximum: CGFloat,
                    dates: [Date]){
        chartView.gridLineColor = .gray200
        chartView.barWidth = datasource.count <= 7 ? 12 : 6
        chartView.setupCombinedBarChart(dataSource: datasource,
                                        baseLine: baseLine,
                                        maximum: maximum)
        setupYAxisLabel(maximum: Double(maximum))
        setupXAxisLabel(dates: dates)
    }

    private func setupYAxisLabel(maximum: Double) {
        range1Label.text = 0.clean
        range2Label.text = (maximum / 2).rounded().clean
        range3Label.text = (maximum).rounded().clean
    }

    private func setupXAxisLabel(dates: [Date]) {
        xAxisStackView.subviews.forEach { $0.removeFromSuperview() }
        if dates.count == 7 {
            for date in dates {
                let dateFormattor = DateFormatter()
                dateFormattor.dateFormat = "EE"
                let dateString = dateFormattor.string(from: date)
                xAxisStackView.addArrangedSubview(getLabel(text: dateString))
            }
            xAxisStackView.distribution = .fillEqually
        } else if dates.count > 7 {
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

    private func getLabel(text: String)  -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.inter(type: .regular, size: 12)
        label.textColor = .gray900
        label.textAlignment = .center
        return label
    }
}
