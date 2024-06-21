//
//  ViewForXib.swift
//  Nutritaion-ai
//
//  Created by Mind on 12/02/24.
//

import UIKit

class ViewFromXIB: UIView {

    var customView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit(emptyCheck: true)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit(emptyCheck: false)
    }

    func commonInit(emptyCheck: Bool) -> Void {

        self.clipsToBounds = false
        self.backgroundColor = .clear

        let className = String(describing: type(of: self).self)
        customView = Bundle.module.loadNibNamed(className, owner: self, options: nil)?.first as? UIView
        customView.frame = self.bounds
        if emptyCheck {
            if frame.isEmpty {
                self.bounds = customView.bounds
            }
        }
        self.addSubview(customView)
    }
}
