//
//  WeightTrackingRecordCell.swift
//  PassioNutritionUIModule
//
//  Created by Tushar S on 08/11/24.
//

import UIKit

class WeightTrackingRecordCell: UITableViewCell {

    @IBOutlet private weak var weightLabel: UILabel!
    @IBOutlet private weak var weightUnitLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = DateFormatString.EEE_MMMd
        return df
    }()
    
    private let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = DateFormatString.h_mm_a
        return df
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        weightLabel.text = "150"
        weightUnitLabel.text = "lbs"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLayout(weightTracking: WeightTracking, userProfile: UserProfileModel) {
        let weight = userProfile.units == .imperial ? Double(weightTracking.weight * Conversion.lbsToKg.rawValue) : weightTracking.weight
        weightLabel.text = "\(weight.roundUpDigits(afterDecimal: 1))"
        weightUnitLabel.text = "\(userProfile.selectedWeightUnit)"
        
        dateLabel.text = dateFormatter.string(from: weightTracking.date)
        timeLabel.text = timeFormatter.string(from: weightTracking.time)
    }
}
