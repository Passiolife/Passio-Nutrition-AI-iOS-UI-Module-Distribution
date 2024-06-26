//
//  SentTextTableViewCell.swift
//  BaseApp
//
//  Created by Mind on 24/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class SentTextTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
    }

    func setup(datasource: NutritionAdvisorMessageDataSource) {
        messageLabel.text = datasource.content ?? ""
    }
}
