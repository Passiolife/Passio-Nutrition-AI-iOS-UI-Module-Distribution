//
//  CornerHeaderView.swift
//  BaseApp
//
//  Created by Mind on 16/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit

class CornerHeaderView: ViewFromXIB{
    
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var downView: UIView!
    
    
    
    
    var isHeader: Bool = false{
        didSet {
            self.upperView.isHidden = isHeader
            self.downView.isHidden = !isHeader
            self.upperView.roundMyCornerWith(radius: 8, upper: false, down: true)
            self.downView.roundMyCornerWith(radius: 8, upper: true, down: false)
        }
    }
}
