//
//  AlternateNamesCollCell.swift
//  NutritionAISDK
//
//  Created by Nikunj Prajapati on 05/01/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class AlternateNamesCollCell: UITableViewCell {

    @IBOutlet weak var alternateNameCollectionView: UICollectionView! {
        didSet {
            alternateNameCollectionView.register(nibName: "AlternateNamesSearchCell")
        }
    }

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate,
                                             forRow row: Int) {
        alternateNameCollectionView.delegate = dataSourceDelegate
        alternateNameCollectionView.dataSource = dataSourceDelegate
        alternateNameCollectionView.reloadData()
    }
}
