//
//  NAMultiImageCell.swift
//  
//
//  Created by Pratik on 18/09/24.
//

import UIKit

class NAMultiImageCell: UITableViewCell {

    @IBOutlet weak var imagesCollection: UICollectionView!
    var message: NAMessageModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        basicSetup()
    }

    func basicSetup() {
        self.selectionStyle = .none
        imagesCollection.registerNib(NAImageCollectionCell.self)
        imagesCollection.collectionViewLayout = compositionalLayout
    }
    
    func load(message: NAMessageModel) {
        self.message = message
        imagesCollection.reloadData()
    }
    
    let compositionalLayout: UICollectionViewCompositionalLayout = {
        let fraction: CGFloat = 1.0
        
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(160))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
        section.orthogonalScrollingBehavior = .continuous
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            let width = environment.container.effectiveContentSize.width
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - width / 2.0)
                let minScale: CGFloat = 0.8
                let maxScale: CGFloat = 1
                let scale: CGFloat = minScale + (1.0 - minScale) * exp(-distanceFromCenter / (width / 2))
                //let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        return UICollectionViewCompositionalLayout(section: section)
    }()
}

extension NAMultiImageCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return message?.imageFileNames.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(cellClass: NAImageCollectionCell.self, forIndexPath: indexPath)
        guard let image = message?.image(atIndex: indexPath.item) else { return UICollectionViewCell() }
        cell.load(image: image)
        return cell
    }
}
