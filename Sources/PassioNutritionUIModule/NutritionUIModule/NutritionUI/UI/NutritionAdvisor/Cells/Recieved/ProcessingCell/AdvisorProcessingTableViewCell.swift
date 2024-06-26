//
//  AdvisorProcessingTableViewCell.swift
//  
//
//  Created by Davido Hyer on 6/25/24.
//

import Lottie
import UIKit

class AdvisorProcessingTableViewCell: UITableViewCell {
    @IBOutlet weak var animation: LottieAnimationView!
    @IBOutlet weak var messageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadAnimation()
    }
    
    private func loadAnimation() {
        animation.isHidden = false
        animation.animation =  LottieAnimation.named("TypingIndicator", bundle: .module)
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 1
        animation.play(fromProgress: 0, toProgress: 0.5, loopMode: .loop)
        
        let path = UIBezierPath(roundedRect:messageView.bounds,
                                byRoundingCorners:[.topRight, .bottomRight, .topLeft],
                                cornerRadii: CGSize(width: 6, height:  6))

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        messageView.layer.mask = maskLayer
    }
}
