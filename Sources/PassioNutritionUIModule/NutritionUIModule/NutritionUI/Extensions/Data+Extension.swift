//
//  Data+Extension.swift
//  PassioDemoApp
//
//  Created by zvika on 6/14/21.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import Foundation
import CryptoKit

extension Data {

    var md5HashString: String {
        let computed = Insecure.MD5.hash(data: self )
        let insecure = computed.map { String(format: "%02hhx", $0) }.joined()
        return insecure
    }
}
