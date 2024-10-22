//
//  UINib+Extension.swift
//  BaseApp
//
//  Created by Zvika on 10/5/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

extension UINib {

    static func nibFromBundle(nibName: String, bundle: Bundle = PassioInternalConnector.shared.bundleForModule) -> UINib {
        UINib(nibName: nibName,
              bundle: bundle)
    }
}
