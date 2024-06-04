//
//  StringProtocol+Extension.swift
//  PassioDemoApp
//
//  Created by zvika on 9/27/21.
//  Copyright © 2021 Passio Inc. All rights reserved.
//

import Foundation

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
