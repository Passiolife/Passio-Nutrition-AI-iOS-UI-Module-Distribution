//
//  AnalyzingView.swift
//  
//
//  Created by Pratik on 16/09/24.
//

import UIKit
import Lottie

class AnalyzingView: UIView
{
    @IBOutlet var contentView: UIView!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var loader: LottieAnimationView!

    init(frame: CGRect, bundle: Bundle = PassioInternalConnector.shared.bundleForModule) {
        super.init(frame: frame)
        bundle.loadNibNamed(String(describing: AnalyzingView.self), owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        basicSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func basicSetup() {
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 8
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        loadAnimation()
    }
    
    private func loadAnimation() {
        loader.isHidden = false
        loader.animation = LottieAnimation.named("TypingIndicator", bundle: .module)
        loader.contentMode = .scaleAspectFit
        loader.loopMode = .loop // .autoReverse
        loader.animationSpeed = 0.8
        loader.play(fromProgress: 0, toProgress: 0.5, loopMode: .loop)
    }
}
