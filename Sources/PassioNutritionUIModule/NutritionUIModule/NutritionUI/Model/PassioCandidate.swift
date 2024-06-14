//
//  PassioBeacon.swift
//  BaseApp
//
//  Created by Zvika on 9/14/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

struct PassioCandidate {
    let passioID: PassioID
    let confidence: Double
}
