//
//  ReceivedTextCell.swift
//  
//
//  Created by Pratik on 16/09/24.
//

import UIKit
import SwiftyMarkdown

class ReceivedTextCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var findFoodButton: UIButton!
    
    var findFoodButtonTap: ((UIButton)->())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        basicSetup()
    }

    func basicSetup() {
        self.selectionStyle = .none
        findFoodButton.titleLabel?.font = .inter(type: .regular, size: 14)
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 8
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    func setupMD(md: inout SwiftyMarkdown) {
        
        md.setFontNameForAllStyles(with: UIFont.inter(type: .regular).familyName)
        md.setFontSizeForAllStyles(with: 14)
        md.setFontColorForAllStyles(with: .white)
        
        md.h1.fontName = UIFont.inter(type: .semiBold).fontName
        md.h2.fontName = UIFont.inter(type: .semiBold).fontName
        md.h3.fontName = UIFont.inter(type: .semiBold).fontName
        md.h4.fontName = UIFont.inter(type: .semiBold).fontName
        md.h5.fontName = UIFont.inter(type: .semiBold).fontName
        md.h6.fontName = UIFont.inter(type: .semiBold).fontName
        md.body.fontName = UIFont.inter(type: .regular).fontName
        md.bold.fontName = UIFont.inter(type: .bold).fontName
        
        md.h1.fontSize = 24
        md.h2.fontSize = 22
        md.h3.fontSize = 20
        md.h4.fontSize = 18
        md.h5.fontSize = 16
        md.h6.fontSize = 14
        md.body.fontSize = 14
        md.bold.fontSize = 14
    }
    
    func load(message: NAMessageModel) {
        guard let advisorResponse = message.response else { return }
        let markupString = advisorResponse.markupContent.trimmingCharacters(in: .whitespacesAndNewlines)
        var md = SwiftyMarkdown(string: markupString ?? "")
        setupMD(md: &md)
        messageLabel.attributedText = md.attributedString()
        findFoodButton.isHidden = !message.canFindFood
    }
    
    @IBAction func findFoodButtonTapped(_ sender: UIButton) {
        findFoodButtonTap?(sender)
    }
}
