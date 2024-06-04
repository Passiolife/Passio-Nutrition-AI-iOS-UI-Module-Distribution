//
//  QuickAddCollectionViewCell.swift
//  BaseApp
//
//  Created by Mind on 13/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class QuickAddCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var suggestionNameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    var passioIDForCell: String = ""
    var onQuickAddSuggestion: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.roundMyCorner()
    }

    func setup(foodResult: SuggestedFoods) {
        passioIDForCell = foodResult.iconId
        imageView.setFoodImage(id: foodResult.iconId,
                               passioID: foodResult.iconId,
                               entityType: .item,
                               connector: PassioInternalConnector.shared) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        suggestionNameLabel.text = foodResult.name.capitalized
    }

    @IBAction func onQuickAddSuggestion(_ sender: UIButton) {
        onQuickAddSuggestion?()
    }
}
