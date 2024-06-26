//
//  SentMultiImageTableViewCell.swift
//  
//
//  Created by Davido Hyer on 6/21/24.
//

import UIKit

class SentMultiImageTableViewCell: UITableViewCell {
    @IBOutlet weak var imageStackParentView: UIView?
    
    private var imageStack: StackedItemsView<String, SentMultiImageCollectionViewCell>?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
    }

    func setup(datasource: NutritionAdvisorMessageDataSource) {
        if imageStack == nil {
            let imageStack = StackedItemsView<String, SentMultiImageCollectionViewCell>()
            if let imageStackParentView {
                imageStackParentView.addSubview(imageStack)
                imageStack.translatesAutoresizingMaskIntoConstraints = false
                
                let containerConstraints = [
                    imageStack.leadingAnchor.constraint(equalTo: imageStackParentView.leadingAnchor),
                    imageStack.trailingAnchor.constraint(equalTo: imageStackParentView.trailingAnchor),
                    imageStack.topAnchor.constraint(equalTo: imageStackParentView.topAnchor),
                    imageStack.bottomAnchor.constraint(equalTo: imageStackParentView.bottomAnchor)
                ]
                
                NSLayoutConstraint.activate(containerConstraints)
            }
            self.imageStack = imageStack
        }
        imageStack?.items = datasource.images
        imageStack?.configureItemHandler = { [weak self] fileName, cell in
            if let image = self?.image(fileName: fileName) {
                cell.setup(image: image)
            }
        }
//        imageStack.selectionHandler = { [weak self] item, index in
//
//        }
    }
    
    private func image(fileName: String) -> UIImage? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
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
}
