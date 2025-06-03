//
//  File.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 30/05/25.
//

import Foundation
import UIKit

enum Tip {
    
    case captureNutritionFacts
    
    var title: String {
        switch self {
        case .captureNutritionFacts:
            return "Capture Nutrition Facts Label"
        }
    }
    
    var desc: String {
        switch self {
        case .captureNutritionFacts:
            return "Capture a photo of the entire Nutrition Facts Label"
        }
    }
    
    var image: UIImage {
        switch self {
        case .captureNutritionFacts:
            return UIImage.imageFromBundle(named: "tipCaptureNF") ?? UIImage()
        }
    }
}
