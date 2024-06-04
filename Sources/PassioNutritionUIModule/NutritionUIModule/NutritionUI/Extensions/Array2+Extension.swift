//
//  Array+Extension.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 04/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {

    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }

    func unique<T: Hashable>(map: ((Element) -> (T))) -> [Element] {
        var set = Set<T>()
        var arrayOrdered = [Element]()
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        return arrayOrdered
    }
}
