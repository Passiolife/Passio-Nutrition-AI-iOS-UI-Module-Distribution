//
//  ThumbnailImageCollectionCell.swift
//  Nutrition UI
//
//  Created by Tamás Sengel on 6/28/21.
//  Copyright © 2021 Passio Inc. All rights reserved.

import UIKit

final class ThumbnailImageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!

    var onDelete: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        foodImageView.layer.cornerRadius = 8
        foodImageView.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.dropShadow(radius: 8,
                        offset: .init(width: 0, height: 2),
                        color: .black.withAlphaComponent(0.3),
                        shadowRadius: 2,
                        shadowOpacity: 1,
                        useShadowPath: true)
    }

    @IBAction func onDeleteImage(_ sender: UIButton) {
        onDelete?(sender.tag)
    }

    func configure(with image: UIImage, index: Int, isHidden: Bool = true) {
        foodImageView.image = image
        deleteButton.tag = index
        deleteButton.showHideView(isHidden: isHidden)
    }
}
