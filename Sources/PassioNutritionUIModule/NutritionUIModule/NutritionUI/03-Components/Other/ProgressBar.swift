//
//  File.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 21/05/25.
//

import UIKit

@IBDesignable
class ProgressBar: UIView {
    
    private let progressView = UIView()
    
    // MARK: - Inspectable Properties
    
    @IBInspectable var progress: CGFloat = 0.0 {
        didSet {
            updateProgress(animated: true)
        }
    }
    
    @IBInspectable var trackColor: UIColor = .systemGray5 {
        didSet {
            self.backgroundColor = trackColor
        }
    }
    
    @IBInspectable var progressColor: UIColor = .systemBlue {
        didSet {
            progressView.backgroundColor = progressColor
        }
    }
    
    @IBInspectable var isRound: Bool = true {
        didSet {
            updateCornerRadius()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            updateCornerRadius()
        }
    }
    
    private func updateCornerRadius() {
        let value = min(bounds.width, bounds.height) / 2
        self.layer.cornerRadius = isRound ? value : cornerRadius
        progressView.layer.cornerRadius = isRound ? value : cornerRadius
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = true
        self.backgroundColor = trackColor
        progressView.backgroundColor = progressColor
        progressView.clipsToBounds = true
        addSubview(progressView)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
        updateProgress(animated: false)
    }
    
    private func updateProgress(animated: Bool) {
        
        let clamped = min(max(progress, 0.0), 1.0)
        let newWidth = bounds.width * clamped
        let newFrame = CGRect(x: 0, y: 0, width: newWidth, height: bounds.height)
        
        if animated {
            let duration = progress < 1 ? 0.25 : 0.45
            UIView.animate(withDuration: duration) {
                self.progressView.frame = newFrame
            }
        } else {
            progressView.frame = newFrame
        }
    }
}
