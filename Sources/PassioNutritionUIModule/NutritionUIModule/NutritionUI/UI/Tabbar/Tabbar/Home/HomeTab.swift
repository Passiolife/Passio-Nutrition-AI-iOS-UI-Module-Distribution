//
//  HomeTab.swift
//  Nutritaion-ai
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
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.6
    }

    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?(sender)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        return plusButton.frame.contains(point) ? self.plusButton : super.hitTest(point, with: event)
    }
}
