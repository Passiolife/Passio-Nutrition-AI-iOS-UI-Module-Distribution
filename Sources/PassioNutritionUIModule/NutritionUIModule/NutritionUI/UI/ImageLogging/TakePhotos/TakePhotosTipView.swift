//
//  File.swift
//  
//
//  Created by Davido Hyer on 6/20/24.
//

import Foundation
import UIKit

protocol TakePhotosTipViewDelegate: AnyObject {
    func dismiss(sender: TakePhotosTipView)
}

class TakePhotosTipView: UIView {
    weak var delegate: TakePhotosTipViewDelegate?
    
    @IBAction func okAction(_ sender: UIButton) {
        delegate?.dismiss(sender: self)
    }
}
