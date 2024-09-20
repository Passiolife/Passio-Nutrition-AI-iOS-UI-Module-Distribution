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

//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//        basicSetup()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        print("Init header view: coder")
//        basicSetup()
//    }
    
    func basicSetup() {
        messageLabel.font = .inter(type: .regular, size: 14)
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 8
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func load(title: String) {
        basicSetup()
        messageLabel.text = title
    }
}
