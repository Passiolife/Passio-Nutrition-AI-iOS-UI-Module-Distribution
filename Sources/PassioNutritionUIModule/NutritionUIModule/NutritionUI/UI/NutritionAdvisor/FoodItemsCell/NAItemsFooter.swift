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
    
    var actionButtonTap: ((UIButton)->())? = nil

    func basicSetup() {
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 8
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        actionButton.titleLabel?.font = .inter(type: .regular, size: 14)
        actionButton.setTitle("Log Selected", for: .normal)
    }
    
    func load() {
        basicSetup()
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        actionButtonTap?(sender)
    }
}
