//
//  InvisibleCollectionViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/2/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class InvisibleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lableInvisibleName: UILabel!
    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
