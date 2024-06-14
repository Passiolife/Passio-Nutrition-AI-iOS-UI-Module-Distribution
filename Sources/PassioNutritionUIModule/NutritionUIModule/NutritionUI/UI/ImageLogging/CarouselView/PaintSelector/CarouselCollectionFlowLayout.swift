//
//  CarouselCollectionFlowLayout.swift
//  PaintsAI
//
//  Created by Tamás Sengel on 6/28/21.
//  Copyright © 2021 Passio Inc. All rights reserved.
//

import UIKit

final class CarouselCollectionFlowLayout: UICollectionViewFlowLayout {

    let zoomedOutFactor: Double = 0.5
    let standardSize: Double = 80
    let standardSpacing: Double = 8
    let offsetExponentialBaseNumber: Double = 2.4
    let offsetModeThreshold: Double = 5
    var isFewerItemLayout: Bool = false

    var offsetDistanceDividend: Double {
        let screenWidth = UIScreen.main.bounds.width
        return min(60, screenWidth / 9)
    }
    var offsetCenterTargetOffset: Double {
        pow(offsetExponentialBaseNumber, offsetModeThreshold / offsetDistanceDividend)
    }
    var maxWidth: Double {
        (collectionView as? InfiniteCollectionView)?.maxWidth ?? 0
    }
    var zoomActivationDistance: Double {
        min(maxWidth, UIScreen.main.bounds.width) / 2
    }

    override init() {
        super.init()

        scrollDirection = .horizontal
        minimumInteritemSpacing = 0
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func updateLayout() {

        guard let collectionView = collectionView else { return }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let screenWidth = UIScreen.main.bounds.width

        if !(1...4).contains(numberOfItems) {

            isFewerItemLayout = false
            let inset = collectionView.adjustedContentInset
            let horizontalInsets = (collectionView.frame.width - inset.right - inset.left - itemSize.width) / 2

            sectionInset = .init(top: 0,
                                 left: horizontalInsets,
                                 bottom: 0,
                                 right: horizontalInsets)
            minimumLineSpacing = 0
            itemSize = .init(width: round(min(maxWidth, screenWidth) / 10),
                             height: collectionView.bounds.height)

        } else {

            isFewerItemLayout = true
            let spacings = standardSpacing * Double(numberOfItems - 1)
            let horizontalInsets = (screenWidth - (standardSize * Double(numberOfItems) + spacings)) / 2

            sectionInset = .init(top: 0,
                                 left: horizontalInsets,
                                 bottom: 0,
                                 right: horizontalInsets)
            minimumLineSpacing = standardSpacing
            itemSize = .init(width: standardSize,
                             height: collectionView.bounds.height)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        guard let collectionView = collectionView,
              let superAttributes = super.layoutAttributesForElements(in: rect),
              collectionView.numberOfItems(inSection: 0) > 4 else {
            return super.layoutAttributesForElements(in: rect)
        }

        let offsetCenterTargetOffset = self.offsetCenterTargetOffset
        let rectAttributes = superAttributes.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)

        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {

            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / zoomActivationDistance

            let zoom = 1 - (1 - zoomedOutFactor) * (normalizedDistance.magnitude)

            let offsetX: Double = {
                if abs(distance) < offsetModeThreshold {
                    return distance / offsetModeThreshold * offsetCenterTargetOffset
                }
                return (distance > 0 ? 1 : -1) * pow(offsetExponentialBaseNumber,
                                                     abs(distance / offsetDistanceDividend))
            }()

            let scaleTransform = CATransform3DMakeScale(zoom, zoom, 1)
            let offsetTransform = CATransform3DMakeTranslation(offsetX, 0, 0)
            attributes.transform3D = CATransform3DConcat(scaleTransform, offsetTransform)
            attributes.zIndex = Int((zoom * 100).rounded())
            attributes.isHidden = abs(offsetX) > 100
        }
        return rectAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard let collectionView = collectionView,
              collectionView.numberOfItems(inSection: 0) > 4 else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }
        let targetRect = CGRect(x: proposedContentOffset.x,
                                y: 0,
                                width: collectionView.frame.width,
                                height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else {
            return .zero
        }

        var offsetAdjustment = Double.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        return .init(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return (collectionView?.numberOfItems(inSection: 0) ?? 0) > 4
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {

        let superContext = super.invalidationContext(forBoundsChange: newBounds)
        guard let flowContext = superContext as? UICollectionViewFlowLayoutInvalidationContext else {
            return .init()
        }
        guard let collectionView = collectionView,
              collectionView.numberOfItems(inSection: 0) > 4 else {
            return superContext
        }
        flowContext.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView.bounds.size
        return flowContext
    }
}
