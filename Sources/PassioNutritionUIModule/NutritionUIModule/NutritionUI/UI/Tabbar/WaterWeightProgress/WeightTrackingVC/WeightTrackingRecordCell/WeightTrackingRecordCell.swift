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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        weightLabel.text = "150"
        weightUnitLabel.text = "lbs"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLayout(weightTracking: WeightTracking) {
        weightLabel.text = "\(weightTracking.weight.clean)"
    }
}
