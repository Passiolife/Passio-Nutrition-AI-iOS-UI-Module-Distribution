//
//  ProcessView.swift
//  Aida
//
//  Created by Pratik on 01/08/24.
//

import UIKit

class ProcessView: UIView
{
    @IBOutlet weak var contentView     : UIView!
    @IBOutlet weak var viewBG          : UIView!
    @IBOutlet weak var viewTransparent : UIView!
    @IBOutlet weak var activityView    : UIActivityIndicatorView!
    @IBOutlet weak var lblActivity     : UILabel!

    // For using Map view through code
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init(frame: CGRect, activity: String) {
        self.init(frame: frame)
        self.lblActivity.text = activity
    }
    
    // For using view through IBOutlet
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.module.loadNibNamed(String(describing: ProcessView.self), owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        setupControls()
    }
    
    private func setupControls() {
        self.lblActivity.font = UIFont.system(16, weight: .regular)
        self.viewBG.layer.cornerRadius = 8
        self.viewTransparent.alpha = 0.9
    }
    
    func updateActivity(_ activity: String) {
        self.lblActivity.text = activity
    }
}
