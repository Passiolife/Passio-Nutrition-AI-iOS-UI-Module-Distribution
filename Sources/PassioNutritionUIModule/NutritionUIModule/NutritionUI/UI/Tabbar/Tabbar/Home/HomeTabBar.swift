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
        middleButton.frame = CGRect(x: self.center.x - 21,
                                    y: self.frame.origin.y - 21,
                                    width: 56,
                                    height: 56)

        let config = UIImage.SymbolConfiguration(pointSize: 23, weight: .medium)
        middleButton.backgroundColor = .primaryColor
        middleButton.tintColor = .white
        middleButton.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        middleButton.addTarget(self, action: #selector(middleButtonAction), for: .touchUpInside)
        self.addSubview(middleButton)
        return middleButton
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        setShadow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        plusButton.center = CGPoint(x: frame.width / 2, y: 0)
        plusButton.layer.shadowPath = UIBezierPath(roundedRect: plusButton.bounds,
                                                   cornerRadius: plusButton.frame.width/2).cgPath
        self.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }

    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?(sender)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        return plusButton.frame.contains(point) ? self.plusButton : super.hitTest(point, with: event)
    }

    private func setShadow() {
        plusButton.dropShadow(radius: plusButton.frame.width/2,
                              offset: .init(width: 0, height: 1),
                              color: .black,
                              shadowRadius: 2,
                              shadowOpacity: 0.21)
        dropShadow(radius: 0,
                   offset: .init(width: 0, height: 20),
                   color: .black,
                   shadowRadius: 25,
                   shadowOpacity: 0.25)
    }
}
