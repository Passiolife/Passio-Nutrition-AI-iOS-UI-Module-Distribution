//
//  SelectedImageCell.swift
//  
//
//  Created by mac-0002 on 17/06/24.
//

import UIKit

class SelectedImageCell: UICollectionViewCell {

    @IBOutlet weak var foodImageView: UIImageView!

    func configureCell(with image: UIImage) {
        foodImageView.image = image
    }
}
