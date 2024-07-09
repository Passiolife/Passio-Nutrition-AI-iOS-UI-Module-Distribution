//
//  PageCollectionView.swift
//  
//
//  Created by Nikunj Prajapati on 21/06/24.
//

import UIKit

protocol PageCollectionDelegate: AnyObject {
    func onPageSelection(index: Int)
}

class PageCollectionView: UICollectionView {

    var titles: [String] = [] {
        didSet {
            reloadData()
        }
    }
    var selectedCellIndexPath: IndexPath = IndexPath(item: 0, section: 0)

    weak var pageCollectionDelegate: PageCollectionDelegate?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {

        register(nibName: "PageCollectionViewCell")
        dataSource = self
        delegate = self
        backgroundColor = .navigationColor
    }
}

// MARK: - UICollectionView Delegates
extension PageCollectionView: UICollectionViewDataSource,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueCell(cellClass: PageCollectionViewCell.self, forIndexPath: indexPath)
        cell.configure(title: titles[indexPath.item],
                       isSelected: selectedCellIndexPath == indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedCellIndexPath != indexPath else { return }
        select(item: indexPath.item)
        pageCollectionDelegate?.onPageSelection(index: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: ScreenSize.width/2, height: 50)
    }

    // MARK: Cell Helper
    private func select(item: Int, in section: Int = 0, animated: Bool = true) {

        guard item < titles.count else { return }

        cleanupSelection()

        let indexPath = IndexPath(item: item, section: section)
        selectedCellIndexPath = indexPath

        let cell = cellForItem(at: indexPath) as? PageCollectionViewCell
        cell?.configure(title: titles[indexPath.item], isSelected: true)

        selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
    }

    private func cleanupSelection() {
        let cell = cellForItem(at: selectedCellIndexPath) as? PageCollectionViewCell
        cell?.configure(title: titles[selectedCellIndexPath.item], isSelected: false)
        selectedCellIndexPath = IndexPath(item: 0, section: 0)
    }
}
