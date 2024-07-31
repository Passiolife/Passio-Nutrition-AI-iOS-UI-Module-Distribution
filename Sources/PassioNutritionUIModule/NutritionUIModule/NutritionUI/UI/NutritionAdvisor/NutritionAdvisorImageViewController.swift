//
//  NutritionAdvisorImageImgridientExtractorViewController.swift
//
//
//  Created by Mind on 30/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class NutritionAdvisorImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contextText: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var autoVideoStart = true
    var originalImageFromPicker: UIImage? {
        didSet {
            imageView.image = originalImageFromPicker
            submitButton.isEnabled = originalImageFromPicker != nil
            if originalImageFromPicker == nil {
                clearResults()
            }
        }
    }
    var extractedIngredients: [PassioAdvisorFoodInfo] = []
    private var isReady: Bool = false

    override func viewDidLoad() {
        title = "Image Recognition"
        setupBackButton()
        navigationController?.isNavigationBarHidden = false
        navigationController?.updateStatusBarColor(color: .white)
        contextText.delegate = self
        tableView.register(nibName: "NutritionAdvisorIngredientCell", bundle: .main)
        // setupAdvisor()
    }

    func setupAdvisor() {
        ProgressHUD.show(presentingVC: self)

        DispatchQueue.global(qos: .userInteractive).async {
            NutritionAdvisor.shared.configure(licenceKey: PassioInternalConnector.shared.nutritionAdvisorKey) {  [weak self] status in
                guard let self else { return }

                ProgressHUD.hide(presentedVC: self)

                switch status {
                case .success:
                    NutritionAdvisor.shared.initConversation { advisorResult in
                        switch advisorResult {
                        case .success:
                            self.isReady = true
                        case .failure(let error):
                            DispatchQueue.main.async {
                                self.showAlertForError(alertTitle: error.errorMessage)
                            }
                        }
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showAlertForError(alertTitle: error.errorMessage)
                    }
                }
            }
        }
    }

    func fetchIngridientFromPhoto(image: UIImage, message: String? = nil) {
        ProgressHUD.show(presentingVC: self)

        DispatchQueue.global(qos: .userInteractive).async {            
            PassioNutritionAI.shared.recognizeImageRemote(image: image, message: message) { [weak self] advisorFoodInfo in
                guard let self else { return }

                DispatchQueue.main.async {
                    ProgressHUD.hide(presentedVC: self)

                    if advisorFoodInfo.count > 0 {
                        self.extractedIngredients = advisorFoodInfo
                        self.tableView.reloadData()
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showAlertForError(alertTitle: "Nutrition Advisor Error:\n Unable to Recognize")
                        }
                    }
                }
            }
        }
    }
    
    func clearResults() {
        extractedIngredients = []
        tableView.reloadData()
    }
    
    @IBAction func onClickSubmit() {
        guard let image = originalImageFromPicker
        else { return }
        
        view.endEditing(true)
        clearResults()
        fetchIngridientFromPhoto(image: image, message: contextText.text)
    }
}

// MARK: - UIImagePickerController Delegate
extension NutritionAdvisorImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func onClickImage() {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.getImagePickerAndSetupUI(withSourceType: .camera)
        }
        let actionGallery = UIAlertAction(title: "Photo Library", style: .default){ [weak self] _ in
            self?.getImagePickerAndSetupUI(withSourceType: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive)
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(actionGallery)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true)
    }

    func getImagePickerAndSetupUI(withSourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = withSourceType
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            originalImageFromPicker = pickedImage
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NutritionAdvisorImageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extractedIngredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(cellClass: NutritionAdvisorIngredientCell.self, forIndexPath: indexPath)
        cell.setup(ingiridient: extractedIngredients[indexPath.row])
        return cell
    }
}

extension NutritionAdvisorImageViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension NutritionAdvisorImageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
