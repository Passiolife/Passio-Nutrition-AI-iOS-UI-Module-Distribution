//
//  RecipeDetailsCell.swift
//  
//
//  Created by Nikunj Prajapati on 02/07/24.
//

import UIKit

class RecipeDetailsCell: UITableViewCell {

    @IBOutlet weak var recipeImageButton: UIButton!
    @IBOutlet weak var editImageLabel: UILabel!
    @IBOutlet weak var backgroundShadowView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameTextField: UITextField!

    var onCreateFoodImage: ((UIImagePickerController.SourceType) -> Void)?
    var recipeName: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        configureUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async { [self] in
            backgroundShadowView.layer.shadowPath = UIBezierPath(roundedRect: backgroundShadowView.bounds,
                                                                 cornerRadius: 8).cgPath
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let name = (recipeNameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
        recipeName?(name)
        endEditing(true)
    }

    private func configureUI() {

        recipeNameTextField.delegate = self
        recipeNameTextField.configureTextField(leftPadding: 13,
                                               radius: 6,
                                               borderColor: .gray300)
        backgroundShadowView.dropShadow(radius: 8,
                                        offset: CGSize(width: 0, height: 1),
                                        color: .black.withAlphaComponent(0.06),
                                        shadowRadius: 2,
                                        shadowOpacity: 1)
        let str = "Edit Image".toMutableAttributedString
        str.apply(attribute: [.foregroundColor: UIColor.primaryColor,
                              .underlineColor: UIColor.primaryColor,
                              .underlineStyle: NSUnderlineStyle.single.rawValue],
                  subString: "Edit Image")
        editImageLabel.attributedText = str
        configureImageViewWithMenu()
    }

    private func configureImageViewWithMenu() {

        recipeImageButton.showImagePickerMenu(
            cameraAction: { [weak self] _ in
                self?.onCreateFoodImage?(.camera)
            },
            photosAction: { [weak self] _ in
                self?.onCreateFoodImage?(.photoLibrary)
            }
        )
    }

    func configureCell(with record: FoodRecordV3, isShowFoodIcon: Bool) {

        recipeNameTextField.text = record.name

        if isShowFoodIcon {
            PassioInternalConnector.shared.fetchUserFoodImage(with: record.iconId) { [weak self] image in
                if let image {
                    DispatchQueue.main.async {
                        self?.recipeImageView.image = image
                    }
                } else {
                    self?.recipeImageView.setFoodImage(id: record.iconId,
                                                       passioID: record.iconId,
                                                       entityType: record.entityType,
                                                       connector: PassioInternalConnector.shared) { image in
                        DispatchQueue.main.async {
                            self?.recipeImageView.image = image
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension RecipeDetailsCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let name = (textField.text ?? "").trimmingCharacters(in: .whitespaces)
        recipeName?(name)
    }
}
