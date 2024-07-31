//
//  NutritionAdvisorDataSource.swift
//  BaseApp
//
//  Created by Mind on 24/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

enum MessageType: Codable {
    case sendMessage
    case sendImage
    case sendMultiImage
    case receivedMessage
    case receivedIngredients
    case advisorAnalyzing
    case processing
    case discoveredFoods
    case loggedFoods
}

struct NutritionAdvisorMessageDataSource: Codable {
    var imageFileName: String?
    var content: String?
    var type: MessageType?
    var response: PassioAdvisorResponse?
    var images: [String] = []
    var foodItems: [NutritionAdvisorLoggedFood] = []
    var isLogged: Bool = false

    init(foodItems: [NutritionAdvisorLoggedFood], isLogged: Bool = false) {
        self.foodItems = foodItems
        self.type = .discoveredFoods
        self.isLogged = isLogged
    }
    
    init(type: MessageType?) {
        self.type = type
    }
    
    init(response: PassioAdvisorResponse?) {
        self.response = response
        self.type = .receivedMessage
    }

    init(image: UIImage) {
        type = .sendImage
        let name = "\(UUID().uuidString).png"
        if NutritionAdvisorMessageDataSource.saveImageInDocumentDirectory(image: image, fileName: name) != nil {
            imageFileName = name
        }
    }
    
    init(images: [UIImage]) {
        type = .sendMultiImage
        for image in images {
            let name = "\(UUID().uuidString).png"
            if NutritionAdvisorMessageDataSource.saveImageInDocumentDirectory(image: image, fileName: name) != nil {
                self.images.append(name)
            }
        }
    }

    init(content: String) {
        self.type = .sendMessage
        self.content = content
    }

    public static func saveImageInDocumentDirectory(image: UIImage, fileName: String) -> URL? {

        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.pngData() {
            do {
                try imageData.write(to: fileURL, options: .atomic)
                return fileURL
            } catch {
                print("Error saving image:- \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }

    public func image() -> UIImage? {
        guard let fileName = imageFileName,
              let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error retrieving image:- \(error.localizedDescription)")
        }
        return nil
    }
    
    public func multiImage(index: Int) -> UIImage? {
        guard images.count > index,
              let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first 
        else { return nil }
        
        let fileName = images[index]
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error retrieving image:- \(error.localizedDescription)")
        }
        return nil
    }
    
    public func rowHeight() -> CGFloat {
        return 100
    }
}

struct NutritionAdvisorLoggedFood: Codable {
    let selected: Bool
    let food: PassioAdvisorFoodInfo
}
