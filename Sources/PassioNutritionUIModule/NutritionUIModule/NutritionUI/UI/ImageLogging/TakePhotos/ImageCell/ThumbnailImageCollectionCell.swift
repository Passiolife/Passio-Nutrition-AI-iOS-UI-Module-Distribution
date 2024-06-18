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

    private let colorShadowLayer = CALayer()

    var isFirstLayoutTime = true
    var onDelete: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        foodImageView.layer.cornerRadius = 8
        foodImageView.layer.masksToBounds = true

        colorShadowLayer.shadowColor = UIColor.black.cgColor
        colorShadowLayer.shadowOpacity = 0.25
        colorShadowLayer.shadowRadius = 4
        colorShadowLayer.shadowOffset = .init(width: 0, height: 4)
        layer.insertSublayer(colorShadowLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isFirstLayoutTime {
            isFirstLayoutTime = false
            CALayer.performWithoutAnimation {
                layoutIfNeeded()
            }
        }

        DispatchQueue.main.async { [self] in
            CALayer.performWithoutAnimation {
                colorShadowLayer.frame = foodImageView.bounds
                colorShadowLayer.shadowPath = .init(
                    roundedRect: foodImageView.bounds,
                    cornerWidth: 8,
                    cornerHeight: 8,
                    transform: nil
                )
            }
        }
        foodImageView.setNeedsLayout()
    }

    @IBAction func onDeleteImage(_ sender: UIButton) {
        onDelete?(sender.tag)
    }

    func configure(with image: UIImage, index: Int) {
        foodImageView.image = image
        deleteButton.tag = index
    }
}
