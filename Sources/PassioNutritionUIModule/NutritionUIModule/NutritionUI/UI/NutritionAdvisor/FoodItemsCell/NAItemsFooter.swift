//
//  NAItemsFooter.swift
//  
//
//  Created by Pratik on 17/09/24.
//

import UIKit

class NAItemsFooter: UITableViewHeaderFooterView
{
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var actionButtonTap: ((UIButton)->())? = nil

    func basicSetup() {
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 8
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        actionButton.titleLabel?.font = .inter(type: .regular, size: 14)
    }
    
    func configure(logStatus: LogStatus) {
        basicSetup()
        
        switch logStatus {
            
        case .notLogged:
            activityIndicator.isHidden = true
            actionButton.isHidden = false
            actionButton.setTitle("Log Selected", for: .normal)
            
        case .logging:
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            actionButton.isHidden = true
            
        case .logged:
            activityIndicator.isHidden = true
            actionButton.isHidden = false
            actionButton.setTitle("View Diary", for: .normal)
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        actionButtonTap?(sender)
    }
}
