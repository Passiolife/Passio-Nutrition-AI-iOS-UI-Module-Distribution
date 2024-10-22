//
//  File.swift
//  
//
//  Created by Nikunj Prajapati on 01/07/24.
//

import Foundation

extension NSObject {

    class var className: String {
        String(describing: self)
    }
}
