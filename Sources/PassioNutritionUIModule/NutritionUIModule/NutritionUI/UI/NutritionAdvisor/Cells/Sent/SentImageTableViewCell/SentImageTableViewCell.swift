//
//  SentImageTableViewCell.swift
//  BaseApp
//
//  Created by Mind on 24/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class SentImageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageImage: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func setup(datasource: NutritionAdvisorMessageDataSource) {
        messageImage?.image = datasource.image()
    }
}
