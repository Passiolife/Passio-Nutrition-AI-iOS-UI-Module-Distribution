//
//  PlusMenuCell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 27/12/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

final class PlusMenuCell: UITableViewCell {


    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.roundMyCorner()
    }
}
