//
//  HomeTabBar.swift
//  Nutrition-ai
//
//  Created by Mind on 12/02/24.
//

import UIKit

final class HomeTabBar: UITabBar {

    var didTapButton: ((_ sender: UIButton) -> Void)?

    lazy var plusButton: UIButton! = {
        let middleButton = UIButton()
        middleButton.awakeFromNib()
        middleButton.frame = CGRect(x: self.center.x - 24,
                                    y: self.frame.origin.y - 24,
                                    width: 64,
                                    height: 64)

        middleButton.setImage(UIImage.imageFromBundle(named: "plus"), for: .normal)
        middleButton.addTarget(self, action: #selector(middleButtonAction), for: .touchUpInside)
        self.addSubview(middleButton)
        return middleButton
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        plusButton.center = CGPoint(x: frame.width / 2, y: -5)
        setShadow()
    }

    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?(sender)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        return plusButton.frame.contains(point) ? self.plusButton : super.hitTest(point, with: event)
    }

    private func setShadow() {
        let plusButtonShadowPath = UIBezierPath(roundedRect: plusButton.imageView?.frame ?? .zero,
                                                cornerRadius: plusButton.frame.width/2)
        plusButton.dropShadow(radius: plusButton.frame.width/2,
                              offset: .init(width: 0, height: 1),
                              color: .black,
                              shadowRadius: 2,
                              shadowOpacity: 0.21,
                              useShadowPath: true,
                              shadowPath: plusButtonShadowPath.cgPath)
        let tabBarShadowPath = UIBezierPath(rect: bounds)
        dropShadow(radius: 0,
                   offset: .init(width: 0, height: 20),
                   color: .black,
                   shadowRadius: 25,
                   shadowOpacity: 0.25,
                   useShadowPath: true,
                   shadowPath: tabBarShadowPath.cgPath)
    }
}
