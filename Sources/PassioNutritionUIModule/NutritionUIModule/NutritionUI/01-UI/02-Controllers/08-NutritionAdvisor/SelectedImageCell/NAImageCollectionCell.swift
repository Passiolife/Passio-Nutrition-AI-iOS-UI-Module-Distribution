//
//  NAImageCollectionCell.swift
//  
//
//  Created by Pratik on 18/09/24.
//

import UIKit

class NAImageCollectionCell: UICollectionViewCell 
{
    @IBOutlet weak var foodImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func load(image: UIImage) {
        foodImageView.image = image
    }
}
