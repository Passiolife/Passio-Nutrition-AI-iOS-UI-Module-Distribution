//
//  SelectedImageCell.swift
//  
//
//  Created by Nikunj Prajapati on 17/06/24.
//

import UIKit

class SelectedImageCell: UICollectionViewCell {

    @IBOutlet weak var foodImageView: UIImageView!

    func configureCell(with image: UIImage) {
        foodImageView.image = image
    }
}
