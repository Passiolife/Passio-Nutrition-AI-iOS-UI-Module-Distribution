//
//  UICollectionView+Extension.swift
//  NaiyaApp
//
//  Created by Nikunj Prajapti on 22/02/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

extension UICollectionView {

    func reloadWithAnimations(withDuration: Double = 0.5) {
        UIView.transition(with: self, duration: withDuration,
                          options: [.transitionCrossDissolve, .allowUserInteraction],
                          animations: {
            self.reloadData()
        })
    }

    func dequeueCell<T: UICollectionViewCell>(cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable CollectionView Cell")
        }
        return cell
    }

    func dequeueReusableView<T: UICollectionReusableView>(ofKind elementKind: String,
                                                          viewType: T.Type,
                                                          for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: elementKind,
                                                          withReuseIdentifier: T.identifier,
                                                          for: indexPath) as? T else {
            fatalError("Unable to Dequeue Collection ReusableView")
        }
        return view
    }

    func register(nibName: String) {
        register(UINib.nibFromBundle(nibName: nibName), forCellWithReuseIdentifier: nibName)
    }
}

extension UICollectionReusableView {

    static var identifier: String {
        return String(describing: self)
    }
}
