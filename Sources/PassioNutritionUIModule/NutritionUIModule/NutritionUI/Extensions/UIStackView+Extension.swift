//
//  UIStackView+Extension.swift
//
//
//  Created by Davido Hyer on 6/21/24.
//

import Foundation
import UIKit

extension UIStackView {
    public func make(
        viewsHidden: [UIView],
        viewsVisible: [UIView],
        animated: Bool,
        completion: (()->Void)? = nil
    ) {
        let viewsHidden = viewsHidden.filter({ $0.superview === self })
        let viewsVisible = viewsVisible.filter({ $0.superview === self })
        
        let blockToSetVisibility: ([UIView], _ hidden: Bool) -> Void = { views, hidden in
            views.forEach({
                $0.isOpaque = false
                $0.isHidden = hidden
            })
        }
        
        let blockToSetAlphaForSubviewsOf: ([UIView], _ alpha: CGFloat) -> Void = { views, alpha in
            views.forEach({ view in
                view.subviews.forEach({ 
                    $0.isOpaque = false
                    $0.alpha = alpha
                })
            })
        }
        
        if !animated {
            blockToSetVisibility(viewsHidden, true)
            blockToSetVisibility(viewsVisible, false)
            blockToSetAlphaForSubviewsOf(viewsHidden, 1)
            blockToSetAlphaForSubviewsOf(viewsVisible, 1)
        } else {
            let allViews = viewsHidden + viewsVisible
            self.layer.removeAllAnimations()
            allViews.forEach { view in
                let oldHiddenValue = view.isHidden
                view.layer.removeAllAnimations()
                view.layer.isHidden = oldHiddenValue
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 2.3,
                               delay: 0.0,
                               usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 1,
                               options: [],
                               animations: {
                    blockToSetAlphaForSubviewsOf(viewsVisible, 1)
                    blockToSetAlphaForSubviewsOf(viewsHidden, 0)
                    
                    blockToSetVisibility(viewsHidden, true)
                    blockToSetVisibility(viewsVisible, false)
                    self.layoutIfNeeded()
                }) { _ in
                    completion?()
                }
            }
        }
    }
}
