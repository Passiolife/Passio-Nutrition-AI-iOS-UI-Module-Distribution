//
//  File.swift
//  
//
//  Created by Pratik on 16/09/24.
//

import UIKit
import PassioNutritionUIModule
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

enum MeassageType: Codable {
    case sendMessage
    case receivedMessage
    case sendSingleImage
    case sendMultiImage
    case receivedFood
}

struct NAMessageModel: Codable {
    
    var type: MeassageType?
    var content: String?
    var imageFileNames: [String] = []
    var response: PassioAdvisorResponse?
    
    var canFindFood: Bool = false
    var isImageResult: Bool = false
    var foodCount: Int {
        response?.extractedIngredients?.count ?? 0
    }
    
    // Send Message
    init(content: String) {
        self.type = .sendMessage
        self.content = content
    }
    
    // Send Image
    init(images: [UIImage]) {
        if images.count == 1 {
            type = .sendSingleImage
            let name = "\(UUID().uuidString).png"
            if NAMessageModel.saveImageInDocumentDirectory(image: images[0], fileName: name) != nil {
                self.imageFileNames.append(name)
            }
        }
        else {
            type = .sendMultiImage
            for image in images {
                let name = "\(UUID().uuidString).png"
                if NAMessageModel.saveImageInDocumentDirectory(image: image, fileName: name) != nil {
                    self.imageFileNames.append(name)
                }
            }
        }
    }
    
    init(response: PassioAdvisorResponse?,
         type: MeassageType,
         isImageResult: Bool = false)
    {
        self.type = type
        self.response = response
        self.isImageResult = isImageResult
        
        if type == .receivedMessage {
            canFindFood = self.response?.tools?.contains("SearchIngredientMatches") ?? false
        }
    }
    
    public static func saveImageInDocumentDirectory(image: UIImage, fileName: String) -> URL? {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        
        if let imageData = image.fixOrientation().pngData() {
            do {
                try imageData.write(to: fileURL, options: .atomic)
                return fileURL
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
//    public func image() -> UIImage? {
//        guard let fileName = imageFileName,
//              let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            return nil
//        }
//        let fileURL = documentsUrl.appendingPathComponent(fileName)
//        do {
//            let image = UIImage(contentsOfFile: fileURL.path)
//            return image
//        } catch {
//            print("Error retrieving image: \(error.localizedDescription)")
//        }
//        return nil
//    }
    
    public func image(atIndex index: Int) -> UIImage? {
        guard imageFileNames.count > index,
              let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return nil }
        
        let fileName = imageFileNames[index]
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let image = UIImage(contentsOfFile: fileURL.path)
            return image
        } catch {
            print("Error retrieving image: \(error.localizedDescription)")
        }
        return nil
    }
}

