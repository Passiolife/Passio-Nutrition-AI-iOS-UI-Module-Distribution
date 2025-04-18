//
//  ImagePicker.swift
//  
//
//  Created by Pratik on 19/09/24.
//

import Foundation
import UIKit
import PhotosUI

protocol ImagePickerDelegate: NSObjectProtocol {
    func didSelect(images: [UIImage])
}

class ImagePicker: NSObject
{
    var selectionLimit: Int = 7
    weak var delegate: ImagePickerDelegate?

    override init() {
        super.init()
    }
    
    func present(on viewController: UIViewController) {
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.isModalInPresentation = true
        picker.delegate = self
        
        DispatchQueue.main.async {
            viewController.present(picker, animated: true)
        }
    }
}

extension ImagePicker: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true) { [weak self] in
            
            if results.count < 1 { return }
            
            var selectedImages: [UIImage] = []
            let itemProviders = results.map(\.itemProvider)
            let dispatchGroup = DispatchGroup()
            
            for itemProvider in itemProviders {
                dispatchGroup.enter()
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { image , error  in
                        if let image = image as? UIImage {
                            selectedImages.append(image)
                            dispatchGroup.leave()
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                } else {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) { [weak self] in
                guard let self else { return }
                if selectedImages.count < 1 { return }
                self.delegate?.didSelect(images: selectedImages)
            }
        }
    }
}
