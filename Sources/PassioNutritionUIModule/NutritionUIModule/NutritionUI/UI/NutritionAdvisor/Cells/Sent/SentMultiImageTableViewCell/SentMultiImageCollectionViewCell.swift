//
//  SentMultiImageCollectionViewCell.swift
//  
//
//  Created by Davido Hyer on 6/21/24.
//

import UIKit

public class SentMultiImageCollectionViewCell: UICollectionViewCell {
    private var imageView: UIImageView?
    
    func setup(image: UIImage) {
        setupCell()
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = false
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerConstraints = [
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(containerConstraints)
        self.imageView = imageView
    }
    
    func setupCell() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }
}
