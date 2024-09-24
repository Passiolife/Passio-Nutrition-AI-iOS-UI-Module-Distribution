//
//  NAItemsHeader.swift
//  
//
//  Created by Pratik on 17/09/24.
//

import UIKit

class NAItemsHeader: UITableViewHeaderFooterView 
{
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    func basicSetup() {
        messageLabel.font = .inter(type: .regular, size: 14)
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 8
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func configure(isImageResult: Bool, logStatus: LogStatus) {
        basicSetup()
        if logStatus == .logged {
            messageLabel.text = NAFoodLoggedTitle
        } else {
            messageLabel.text = isImageResult ? NAImageSearchTitle: NATextSearchTitle
        }
    }
}
