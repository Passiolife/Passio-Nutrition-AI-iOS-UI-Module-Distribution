//
//  PageCollectionViewCell.swift
//  
//
//  Created by Nikunj Prajapati on 21/06/24.
//

import UIKit

class PageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .navigationColor
        bgView.backgroundColor = .navigationColor
    }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        titleLabel.font = isSelected ? .inter(type: .semiBold, size: 20) : .inter(type: .regular, size: 20)
        titleLabel.textColor = isSelected ? .primaryColor : .gray900
    }
}
