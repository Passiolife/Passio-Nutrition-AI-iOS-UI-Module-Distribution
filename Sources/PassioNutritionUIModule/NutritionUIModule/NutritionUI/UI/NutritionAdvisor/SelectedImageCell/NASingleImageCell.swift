//
//  NASingleImageCell.swift
//  
//
//  Created by Pratik on 18/09/24.
//

import UIKit

class NASingleImageCell: UITableViewCell {

    @IBOutlet weak var foodImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        basicSetup()
    }
    
    func basicSetup() {
        self.selectionStyle = .none
    }
    
    func load(message: NAMessageModel) {
        foodImageView.image = message.image(atIndex: 0)
    }
}
