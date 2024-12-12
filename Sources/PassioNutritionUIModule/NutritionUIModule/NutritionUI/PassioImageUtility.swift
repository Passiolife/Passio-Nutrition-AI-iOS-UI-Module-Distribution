//
//  File.swift
//  
//
//  Created by Pratik on 10/10/24.
//

import Foundation
import UIKit

class PassioImageUtility {
    
    static let shared = PassioImageUtility()
    private let fileManager = FileManager.default
    
    func updateUserFoodImage(with id: String, image: UIImage) {
        if let url = urlForSaving(imageId: id) {
            _ = locallyUpdateUserFood(image: image, url: url)
        }
    }
    
    func deleteUserFoodImage(with id: String) {
        if let url = urlForSaving(imageId: id) {
            fileManager.deleteRecordLocally(url: url)
        }
    }
    
    func fetchUserFoodImage(with id: String, completion: @escaping (UIImage?) -> Void) {
        if let url = urlForUserFoodImagesDirectory {
            completion(getUserFoodImageFor(id: id, url: url))
        } else {
            completion(nil)
        }
    }
}

// MARK: Helper

extension PassioImageUtility {
    
    private var urlForUserFoodImagesDirectory: URL? {
        fileManager.createDirectory(with: "passioUserFoodImages")
    }
    
    private func locallyUpdateUserFood(image: UIImage, url: URL) -> Bool {
        do {
            let encodedImageData = image.pngData()
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(atPath: url.path)
            }
            do {
                try encodedImageData?.write(to: url)
                return true
            } catch {
                return false
            }
        } catch {
            return false
        }
    }
    
    private func getUserFoodImageFor(id: String, url: URL) -> UIImage? {
        guard let dirURL = urlForUserFoodImagesDirectory else { return nil }
        do {
            let imagePath = dirURL.appendingPathComponent("\(id).png", isDirectory: false)
            if let imageData = try? Data(contentsOf: imagePath),
               let foodImage = UIImage(data: imageData) {
                return foodImage
            }
        }
        return nil
    }
    
    private func urlForSaving(imageId: String) -> URL? {
        createFile(for: urlForUserFoodImagesDirectory, at: "\(imageId)" + ".png", useJSON: false)
    }

    private func createFile(for url: URL?, at path: String, useJSON: Bool = true) -> URL? {
        guard let dirURL = url else { return nil }
        let path = useJSON ? path.replacingOccurrences(of: "-", with: "") + ".json" : path
        let finalURL = dirURL.appendingPathComponent(path)
        return finalURL
    }
}
