//
//  TrackingRecordCell.swift
//  PassioNutritionUIModule
//
//  Created by Tushar S on 08/11/24.
//

import UIKit

class TrackingRecordCell: UITableViewCell {

    @IBOutlet private weak var bodyMetricValueLabel: UILabel!
    @IBOutlet private weak var measuringUnitLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = DateFormatString.mmmm_dd_yyyy
        return df
    }()
    
    private let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = DateFormatString.h_mm_a
        return df
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bodyMetricValueLabel.text = "150"
        measuringUnitLabel.text = "lbs"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setLayout(weightTracking: WeightTracking, userProfile: UserProfileModel) {
        let weight = userProfile.units == .imperial ? Double(weightTracking.weight * Conversion.lbsToKg.rawValue) : weightTracking.weight
        bodyMetricValueLabel.text = "\(weight.roundDigits(afterDecimal: 1).clean)"
        measuringUnitLabel.text = "\(userProfile.selectedWeightUnit)"
        
        dateLabel.text = dateFormatter.string(from: weightTracking.dateTime)
        timeLabel.text = timeFormatter.string(from: weightTracking.dateTime)
    }
    
    func setLayout(waterTracking: WaterTracking, userProfile: UserProfileModel) {
        let weight = waterTracking.water
        bodyMetricValueLabel.text = "\(weight.roundDigits(afterDecimal: 1).clean)"
        measuringUnitLabel.text = "\(userProfile.waterUnit ?? .oz)"
        
        dateLabel.text = dateFormatter.string(from: waterTracking.dateTime)
        timeLabel.text = timeFormatter.string(from: waterTracking.dateTime)
    }
}
