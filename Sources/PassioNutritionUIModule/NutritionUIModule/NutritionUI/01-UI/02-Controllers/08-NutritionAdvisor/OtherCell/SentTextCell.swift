//
//  SentTextCell.swift
//  
//
//  Created by Pratik on 16/09/24.
//

import UIKit

class SentTextCell: UITableViewCell 
{
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        basicSetup()
    }
    
    func basicSetup() {
        self.selectionStyle = .none
        messageLabel.font = .inter(type: .regular, size: 14)
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 8
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }

    func load(message: NAMessageModel) {
        messageLabel.text = message.content ?? ""
    }
}
