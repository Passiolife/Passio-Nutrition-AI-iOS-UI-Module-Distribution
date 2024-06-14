//
//  InfiniteCollectionView.swift
//  PaintsAI
//
//  Created by Tamás Sengel on 6/28/21.
//  Copyright © 2021 Passio Inc. All rights reserved.
//

import UIKit

protocol InfiniteCollectionViewDataSource: AnyObject {
    func cellForItemAtIndexPath(_ collectionView: UICollectionView,
                                dequeueIndexPath: IndexPath,
                                usableIndexPath: IndexPath) -> UICollectionViewCell
    func numberOfItems(_ collectionView: UICollectionView) -> Int
}

protocol InfiniteCollectionViewDelegate: AnyObject {
    func navigationTapped(_ collectionView: UICollectionView, offset: Int)
}

final class InfiniteCollectionView: UICollectionView {

    var previousScreenWidth: Double = .nan
    var indexOffset = 0
    var firstScrollTime = true
    var fewItemsIndex: Int = 0

    let maxWidth: Double = 500
    let navigationStackView = UIStackView()
    var navigationStackConstraints = [NSLayoutConstraint]()

    var cellCount: Int {
        infiniteDataSource?.numberOfItems(self) ?? 0
    }
    var currentIndexPath: IndexPath? {
        let indexPaths = indexPathsForVisibleItems.sorted()
        let index = (indexPathsForVisibleItems.count - 1) / 2
        if indexPaths.count <= index {
            return nil
        }
        return indexPaths[index]
    }
    var isFewerItemLayout: Bool {
        return (flowLayout?.isFewerItemLayout) ?? false
    }
    var repeatCount: Int {
        guard cellCount > 4 else {
            return 1
        }
        /* The number 401 was chosen because of a technicality. It has to do with the scrolling
         inertia of the collection view and some UIScrollView delegate stuff in the background
         that won't work properly if the number of items were less (To make a long story short,
         the scroll view deceleration animation needs a proper amount of space to calculate the
         ending point of the deceleration and if there are too few items in the collection view,
         it would stop at an incorrect x coordinate otherwise)
         */
        return 401
    }
    var isFinishedInitializing: (() -> Void)?

    fileprivate var cellPadding: Double = 0
    fileprivate var cellWidth: Double = 0
    fileprivate var cellHeight: Double = 0

    fileprivate var contentWidth: Double {
        Double(cellCount) * (cellWidth + cellPadding)
    }
    fileprivate var navigationCarouselButtonCount: Int {
        Int(min(maxWidth, UIScreen.main.bounds.width) / 80) * 2 + 1
    }

    weak var infiniteDataSource: InfiniteCollectionViewDataSource?
    weak var infiniteDelegate: InfiniteCollectionViewDelegate?

    fileprivate var flowLayout: CarouselCollectionFlowLayout? {
        collectionViewLayout as? CarouselCollectionFlowLayout
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        configureCollectionView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureCollectionView()
    }

    private func configureCollectionView() {
        dataSource = self
        contentInsetAdjustmentBehavior = .always
        showsHorizontalScrollIndicator = false
        semanticContentAttribute = .forceLeftToRight
        setupCellDimensions()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let screenWidth = UIScreen.main.bounds.width
        let numberOfItems = numberOfItems(inSection: 0)

        if previousScreenWidth != screenWidth {
            previousScreenWidth = screenWidth

            flowLayout?.updateLayout()
            setupCellDimensions()
            updateNavigationStackView()
        }

        navigationStackView.frame = bounds

        guard numberOfItems > 4 else { return }

        let currentOffset = contentOffset
        let contentWidth = self.contentWidth
        let centerOffsetX = (Double(repeatCount) * contentWidth - bounds.size.width) / 2
        let distanceFromCenter = centerOffsetX - currentOffset.x

        guard abs(distanceFromCenter) > contentWidth / 4 else {
            return
        }

        let cellDistance = distanceFromCenter / (cellWidth + cellPadding)
        let shiftCells = Int((cellDistance > 0) ? floor(cellDistance) : ceil(cellDistance))
        var offsetCorrection = (abs(cellDistance).truncatingRemainder(dividingBy: 1)) * (cellWidth + cellPadding)
        offsetCorrection *= contentOffset.x < centerOffsetX ? -1 : 1
        contentOffset = .init(x: centerOffsetX + offsetCorrection, y: currentOffset.y)

        indexOffset += getCorrectedIndex(shiftCells)
        reloadData()
    }

    fileprivate func setupCellDimensions() {

        guard let flowLayout = flowLayout else {
            return
        }
        cellPadding = flowLayout.minimumInteritemSpacing
        cellWidth = flowLayout.itemSize.width
        cellHeight = flowLayout.itemSize.height
    }

    fileprivate func updateNavigationStackView() {
        for subview in navigationStackView.arrangedSubviews {
            navigationStackView.removeArrangedSubview(subview)
        }

        let startPlaceholderView = UIView()
        navigationStackView.addArrangedSubview(startPlaceholderView)

        updateNavigationButtons()

        let endPlaceholderView = UIView()
        navigationStackView.addArrangedSubview(endPlaceholderView)
        endPlaceholderView.widthAnchor.constraint(equalTo: startPlaceholderView.widthAnchor).isActive = true

        navigationStackView.axis = .horizontal
        navigationStackView.distribution = .fill
        navigationStackView.alignment = .fill
        navigationStackView.spacing = 0
        navigationStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if navigationStackView.superview == nil {
            addSubview(navigationStackView)
        }
    }

    fileprivate func updateNavigationButtons() {

        let isFewColors = (1...4).contains(numberOfItems(inSection: 0))
        let buttonCount = navigationCarouselButtonCount
        let maxIndex = (buttonCount - 1) / 2

        let range: ClosedRange<Int> = {
            if isFewColors {
                return 0...numberOfItems(inSection: 0) - 1
            }
            return -maxIndex...maxIndex
        }()

        for index in range {

            let navigationView = UIView()
            navigationView.tag = index

            let tapGestRec = UITapGestureRecognizer()
            tapGestRec.addTarget(self, action: #selector(navigationTapped(_:)))
            navigationView.addGestureRecognizer(tapGestRec)

            let constant: Double = {
                if let flowLayout = flowLayout,
                   isFewColors {
                    return flowLayout.standardSize + flowLayout.standardSpacing
                }
                if index == 0 {
                    return 80
                }
                let percentage = Double(maxIndex - abs(index)) / Double(maxIndex)
                let base = min(maxWidth, UIScreen.main.bounds.width) / 11
                return base * 0.8 + base * 0.2 * percentage
            }()

            let widthConstraint = navigationView.widthAnchor.constraint(
                equalToConstant: constant
            )

            widthConstraint.priority = .init(999)
            widthConstraint.isActive = true
            navigationStackConstraints.append(widthConstraint)
            navigationStackView.addArrangedSubview(navigationView)
            isFinishedInitializing?()
        }
    }

    func getCorrectedIndex(_ indexToCorrect: Int) -> Int {
        guard let numberOfCells = infiniteDataSource?.numberOfItems(self),
              numberOfCells != 0 else {
            return 0
        }

        if indexToCorrect < numberOfCells && indexToCorrect >= 0 {
            return indexToCorrect
        }

        let countInIndex = Float(indexToCorrect) / Float(numberOfCells)
        let flooredValue = Int(floor(countInIndex))
        let offset = numberOfCells * flooredValue

        return min(numberOfCells - 1, indexToCorrect - offset)
    }

    func scrollToIndexPath(_ indexPath: IndexPath) {
        // deliberately called twice (iOS is a buggy mess and this doesn't work otherwise)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    @objc fileprivate func navigationTapped(_ sender: UITapGestureRecognizer) {

        guard let currentIndexPath = currentIndexPath else {
            return
        }

        let offset = sender.view?.tag ?? 0

        let itemIndex: Int = if numberOfItems(inSection: 0) < 5 {
            offset
        } else {
            currentIndexPath.item + offset
        }

        if numberOfItems(inSection: 0) > 4 {
            scrollToIndexPath(IndexPath(item: itemIndex, section: 0))
        }

        infiniteDelegate?.navigationTapped(self,
                                           offset: numberOfItems(inSection: 0) < 5 ?
                                           itemIndex: offset)
    }
}

extension InfiniteCollectionView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        guard let dataSource = infiniteDataSource else {
            return 0
        }
        return repeatCount * dataSource.numberOfItems(self)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let dataSource = infiniteDataSource else {
            return .init()
        }

        return dataSource.cellForItemAtIndexPath(
            self,
            dequeueIndexPath: indexPath,
            usableIndexPath: .init(item: getCorrectedIndex(indexPath.item - indexOffset), section: 0)
        )
    }
}

extension InfiniteCollectionView {

    func scrollToPaint(at indexPath: IndexPath, animated: Bool = true) {

        guard canScroll(to: indexPath.row) else {
            // print("error: won't be able to scroll to indexPath: \(indexPath.row)")
            return
        }
        indexOffset = 0
        let actualIndexPath = IndexPath(row: indexPath.row + indexOffset,
                                        section: indexPath.section)

        scrollToItem(at: actualIndexPath, at: .centeredHorizontally, animated: animated)
    }

    func updateLayout() {
        flowLayout?.updateLayout()
        flowLayout?.updateLayout()
        setupCellDimensions()
        updateNavigationStackView()
    }

    func getCenterIndex(shouldUseZeroIndex: Bool = false, fewItemIndex: Int? = nil) -> Int {

        if let fewItemIndex = fewItemIndex {
            return fewItemIndex
        }

        let groupIndex: Int = {
            guard !shouldUseZeroIndex,
                  let currentIndexPath = currentIndexPath else {
                return 0
            }
            return getCorrectedIndex(currentIndexPath.item - indexOffset)
        }()
        return groupIndex
    }

    func canScroll(to index: Int) -> Bool {

        guard let dataSource = infiniteDataSource,
              dataSource.numberOfItems(self) > 0 else {
            return false
        }
        let range = 0...(dataSource.numberOfItems(self) - 1)
        return range.contains(index)
    }
}
