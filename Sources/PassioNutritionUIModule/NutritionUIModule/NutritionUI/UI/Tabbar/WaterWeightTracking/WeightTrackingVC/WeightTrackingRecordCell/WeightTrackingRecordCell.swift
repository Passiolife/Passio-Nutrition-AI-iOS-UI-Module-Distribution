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
        df.dateFormat = DateFormatString.EEEE_MMM_dd_yyyy
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
    }
    
    func setLayout(weightTracking: WeightTracking, userProfile: UserProfileModel) {
        let weight = userProfile.units == .imperial ? Double(weightTracking.weight * Conversion.lbsToKg.rawValue) : weightTracking.weight
        weightLabel.text = "\(weight.roundDigits(afterDecimal: 1).clean)"
        weightUnitLabel.text = "\(userProfile.selectedWeightUnit)"
        
        dateLabel.text = dateFormatter.string(from: weightTracking.dateTime)
        timeLabel.text = timeFormatter.string(from: weightTracking.dateTime)
    }
}
