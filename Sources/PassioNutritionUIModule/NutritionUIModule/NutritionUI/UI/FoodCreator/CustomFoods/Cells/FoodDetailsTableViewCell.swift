//
//  FoodDetailsTableViewCell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 01/05/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

final class FoodDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var editImageLabel: UILabel!
    @IBOutlet weak var createFoodImageView: UIImageView!
    @IBOutlet weak var backgroundShadowView: UIView!
    @IBOutlet weak var createFoodImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var barcodeTextField: UITextField!
    @IBOutlet weak var barcodeTapView: UIView!

    var onCreateFoodImage: ((UIImagePickerController.SourceType) -> Void)?
    var onBarcode: (() -> Void)?

    var isCreateNewFood = true

    override func awakeFromNib() {
        super.awakeFromNib()

        let str = "Edit Image".toMutableAttributedString
        str.apply(attribute: [.foregroundColor: UIColor.primaryColor,
                              .underlineColor: UIColor.primaryColor,
                              .underlineStyle: NSUnderlineStyle.single.rawValue], subString: "Edit Image")
        editImageLabel.attributedText = str
        configureTextFields()
        configureImageViewWithMenu()
        backgroundShadowView.dropShadow(radius: 8,
                                        offset: CGSize(width: 0, height: 1),
                                        color: .black.withAlphaComponent(0.06),
                                        shadowRadius: 2,
                                        shadowOpacity: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundShadowView.layer.shadowPath = UIBezierPath(roundedRect: backgroundShadowView.bounds,
                                                             cornerRadius: 8).cgPath
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}

// MARK: - Cell Helper
extension FoodDetailsTableViewCell {

    struct FoodDetails {
        let name: String
        let brand: String?
        let barcode: String?
        let image: UIImage
    }

    func configureCell(with record: FoodRecordV3) {
        isCreateNewFood = false
        nameTextField.text = record.name
        brandTextField.text = record.details
        barcodeTextField.text = record.barcode
        PassioInternalConnector.shared.fetchUserFoodImage(with: record.iconId) { [weak self] image in
            if let image {
                DispatchQueue.main.async {
                    self?.createFoodImageView.image = image
                }
            } else {
                self?.createFoodImageView.setFoodImage(id: record.iconId,
                                                 passioID: record.iconId,
                                                 entityType: record.entityType,
                                                 connector: PassioInternalConnector.shared) { image in
                    DispatchQueue.main.async {
                        self?.createFoodImageView.image = image
                    }
                }
            }
        }
    }

    var isFoodDetailsValid: (Bool, String?) {
        var errors = [String]()
        if let name = nameTextField.text, name != "" { } else {
            errors.append("name")
        }
        if errors.count > 0 {
            return (false, "Please enter valid \(errors.joined(separator: ", ")).")
        } else {
            return (true, nil)
        }
    }
    var getFoodDetails: FoodDetails {
        FoodDetails(name: nameTextField.text ?? "",
                    brand: brandTextField.text,
                    barcode: barcodeTextField.text ?? "",
                    image: createFoodImageView.image ?? UIImage())
    }

    private func configureTextFields() {
        nameTextField.delegate = self
        brandTextField.delegate = self
        barcodeTextField.delegate = self

        configureTextFieldUI(nameTextField)
        configureTextFieldUI(brandTextField)
        configureTextFieldUI(barcodeTextField)

        let cameraIcon = UIImage(systemName: "camera")?.withTintColor(
            .gray400, renderingMode: .alwaysOriginal
        ).applyingSymbolConfiguration(.init(weight: .medium))

        barcodeTextField.addImageInTextField(isLeftImg: false,
                                             image: cameraIcon ?? UIImage(),
                                             imageFrame: CGRect(x: 0,
                                                                y: 0,
                                                                width: 26,
                                                                height: 20))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBarcodeTapped))
        barcodeTapView.addGestureRecognizer(tapGesture)
    }

    private func configureImageViewWithMenu() {

        let camera = UIAction(title: "Camera", image: UIImage(systemName: "camera")) { [weak self] _ in
            self?.onCreateFoodImage?(.camera)
        }
        let photos = UIAction(title: "Photos", image: UIImage(systemName: "photo")) { [weak self] _ in
            self?.onCreateFoodImage?(.photoLibrary)
        }
        createFoodImageButton.menu = UIMenu(title: "", children: [camera, photos])
        createFoodImageButton.showsMenuAsPrimaryAction = true
    }

    private func configureTextFieldUI(_ textField: UITextField) {
        textField.configureTextField(leftPadding: 13, radius: 6, borderColor: .gray300)
    }

    @objc private func onBarcodeTapped() {
        onBarcode?()
    }
}

// MARK: - UITextField Delegate
extension FoodDetailsTableViewCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            nameTextField.resignFirstResponder()
            brandTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
