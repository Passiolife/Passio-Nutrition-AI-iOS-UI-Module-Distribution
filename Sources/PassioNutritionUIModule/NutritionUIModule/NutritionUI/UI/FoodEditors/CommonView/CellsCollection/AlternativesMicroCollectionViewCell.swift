//
//  AlternativesCollectionViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/2/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class AlternativesMicroCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var labelAlternativeName: UILabel!
    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
