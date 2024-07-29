//
//  AddedToLogView.swift
//  BaseApp
//
//  Created by Zvika on 2/2/22.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class AddedToLogView: UIView {

    init(frame: CGRect,
         withText: String,
         bgColor: UIColor = .black.withAlphaComponent(0.8),
         txtColor: UIColor = .white) {
        super.init(frame: frame)
        let label = UILabel()
        label.text = withText
        label.textColor = .white
        label.font = UIFont.inter(type: .bold, size: 14)
        label.backgroundColor = UIColor.init(hex: "6B7280")?.withAlphaComponent(0.75)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.frame = bounds
        self.roundMyCornerWith(radius: 8)
        addSubview(label)
    }

    func removeAfter(withDuration: Double, delay: Double) {
            UIView.animateKeyframes(withDuration: withDuration,
                                    delay: delay,
                                    options: .calculationModeCubic,
                                    animations: {
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
            })

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
