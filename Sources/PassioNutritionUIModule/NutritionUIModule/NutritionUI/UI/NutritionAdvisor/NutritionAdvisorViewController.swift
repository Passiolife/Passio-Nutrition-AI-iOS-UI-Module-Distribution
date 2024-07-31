//
//  NutritionAdvisorViewController.swift
//  
//
//  Created by Davido Hyer on 6/20/24.
//

import Foundation
import UIKit
import MobileCoreServices

class NutritionAdvisorViewController: InstantiableViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var attachmentsStackView: UIStackView!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photosButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var isReady: Bool = false
    private var datasource: [NutritionAdvisorMessageDataSource] = []
    private var keyboardHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAdvisor()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func onClickSend() {

        let message = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isReady, message != "" else { return }
        append(NutritionAdvisorMessageDataSource(content: message))
        sendMessage(message: message)
        clearTextView()
    }

    @IBAction func onClickImage() {
        let vc = TakePhotosViewController()
        vc.showTip = true
        navigationController?.pushViewController(vc, animated: true)
        return
        
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.getImagePickerAndSetupUI(withSourceType: .camera)
        }
        let actionGallery = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.getImagePickerAndSetupUI(withSourceType: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive)
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(actionGallery)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true)
    }
    
    @IBAction func onClickCamera() {
        let vc = TakePhotosViewController()
        vc.delegate = self
        vc.isStandAlone = false
        vc.showTip = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickPhotos() {
        let vc = SelectPhotosViewController()
        vc.delegate = self
        vc.isStandAlone = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickAttachments() {
        attachmentsStackView.make(viewsHidden: [attachmentButton],
                                  viewsVisible: [cameraButton, photosButton],
                                  animated: false)
    }
}

// MARK: - Helper
extension NutritionAdvisorViewController {

    private func setupUI() {

        NutritionAdvisorCellType.allCases.forEach {
            tableView.register(nibName: $0.rawValue.capitalizingFirst())
        }
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
//        tableView.delegate = self
        
        title = "Nutrition Advisor"
        setupBackButton()
        navigationController?.isNavigationBarHidden = false
        navigationController?.updateStatusBarColor(color: .white)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        hideKeyboardWhenTappedAround()
    }

    func showWelcomeMessage() {

        guard datasource.isEmpty else { return }

        let welcomeMessage = """
         Welcome! I am your AI Nutrition Advisor!

         ###### You can ask me things like:
         • How many calories are in a yogurt?
         • Create me a recipe for dinner?
         • How can I adjust my diet for heart health?

         Lets chat!
         """
        let response = PassioAdvisorResponse(message: NAMessage(threadId: "",
                                                                messageId: "",
                                                                content: welcomeMessage))
        let message = NutritionAdvisorMessageDataSource(response: response)
        append(message)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        )?.cgRectValue {
            keyboardHeight = keyboardSize.height
            UIView.animate(withDuration: 0.3) {
                self.bottomConstraint.constant = self.keyboardHeight
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 0
        }
    }

    private func clearTextView() {
        textView.resignFirstResponder()
        textView.text = ""
        textViewDidChange(self.textView)
    }

    private func append(_ message: NutritionAdvisorMessageDataSource) {
        datasource.append(message)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] () in
            guard let self else { return }
            tableView.scrollToRow(at: IndexPath(row: datasource.count - 1,
                                                section: 0),
                                  at: .top,
                                  animated: true)
        }
    }
}

// MARK: - NutritionAdvisor
extension NutritionAdvisorViewController {

    func setupAdvisor() {

        ProgressHUD.show(presentingVC: self)
        showWelcomeMessage()

        DispatchQueue.global(qos: .userInteractive).async {

            NutritionAdvisor.shared.configure(
                licenceKey: PassioInternalConnector.shared.nutritionAdvisorKey
            ) { [weak self] status in

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

    func sendMessage(message: String) {

        activityIndicator.startAnimating()

        NutritionAdvisor.shared.sendMessage(message: message) { [weak self] advisorResponse in

            guard let self else { return }

            DispatchQueue.main.async {

                switch advisorResponse {

                case .success(let response):
                    self.append(NutritionAdvisorMessageDataSource(response: response))
                case .failure(let error):
                    self.showAlertForError(alertTitle: error.errorMessage)
                }

                self.activityIndicator.stopAnimating()
            }
        }
    }

    func sendImage(image: UIImage) {
        activityIndicator.startAnimating()

        NutritionAdvisor.shared.sendImage(image: image) { [weak self] advisorResponse in

            guard let self else { return }

            DispatchQueue.main.async {

                self.activityIndicator.stopAnimating()

                switch advisorResponse {

                case .success(let response):
                    ProgressHUD.hide(presentedVC: self)
                    self.append(NutritionAdvisorMessageDataSource(response: response))

                case .failure(let error):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.showAlertForError(alertTitle: error.errorMessage)
                    }
                }
            }
        }
    }
    
    func sendImages(images: [UIImage]) {
        activityIndicator.startAnimating()

        var items = [PassioAdvisorFoodInfo]()
        let dispatchGroup = DispatchGroup()
        
        for image in images {
            dispatchGroup.enter()
            PassioCoreSDK.shared.recognizeImageRemote(image: image, resolution: .res_1080, message: nil) { results in
                if let item = results.first {
                    items.append(item)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - UITableViewDataSource
extension NutritionAdvisorViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let datasource = datasource[indexPath.row]

        switch datasource.type {
        case .receivedIngredients:
            return UITableViewCell()

        case .sendImage:
            let cell = tableView.dequeueCell(cellClass: SentImageTableViewCell.self, 
                                             forIndexPath: indexPath)
            cell.setup(datasource: datasource)
            return cell
            
        case .sendMultiImage:
            let cell = tableView.dequeueCell(cellClass: SentMultiImageTableViewCell.self,
                                             forIndexPath: indexPath)
            cell.setup(datasource: datasource)
            return cell

        case .sendMessage:
            let cell = tableView.dequeueCell(cellClass: SentTextTableViewCell.self, 
                                             forIndexPath: indexPath)
            cell.setup(datasource: datasource)
            return cell

        case .receivedMessage:
            let cell = tableView.dequeueCell(cellClass: ReceivedTextTableViewCell.self, 
                                             forIndexPath: indexPath)
            cell.setup(datasource: datasource)
            return cell
            
        case .advisorAnalyzing:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvisorAnalyzingTableViewCell", for: indexPath)
//            let cell = tableView.dequeueCell(cellClass: AdvisorAnalyzingTableViewCell.self,
//                                             forIndexPath: indexPath)
            return cell
            
        case .processing:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvisorProcessingTableViewCell", for: indexPath)
//            let cell = tableView.dequeueCell(cellClass: AdvisorProcessingTableViewCell.self,
//                                             forIndexPath: indexPath)
            return cell

        case .none:
            return UITableViewCell()
        }
    }
}

//extension NutritionAdvisorViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let datasource = datasource[indexPath.row]
//        return datasource.rowHeight()
//    }
//}

// MARK: - UIImagePickerController Delegate
extension NutritionAdvisorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
            append(NutritionAdvisorMessageDataSource(image: pickedImage))
            sendImage(image: pickedImage)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension NutritionAdvisorViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let esmitated = CGSize(width: textView.frame.width, height: .infinity)
        let esmitatedSize = textView.sizeThatFits(esmitated)
        textViewHeightConstraint.constant = esmitatedSize.height
    }
}

extension NutritionAdvisorViewController: UsePhotosDelegate {
    func onImagesSelected(images: [UIImage]) {
        guard isReady
        else { return }
        
        append(NutritionAdvisorMessageDataSource(type: .advisorAnalyzing))
        processImages(images: images)
//        append(NutritionAdvisorMessageDataSource(images: images))
//        for image in images {
//            sendImage(image: image)
//        }
    }
    
    func processImages(images: [UIImage]) {
        let group = DispatchGroup()
        var foods = [PassioAdvisorFoodInfo]()
        
        for image in images {
            group.enter()
            PassioNutritionAI.shared.recognizeImageRemote(image: image) { results in
                if let item = results.first {
                    foods.append(item)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.append(NutritionAdvisorMessageDataSource(
                foodItems: foods.compactMap({
                    NutritionAdvisorLoggedFood(selected: true, food: $0)
                })
            ))
        }
    }
    
    func processFoods(foods: [PassioAdvisorFoodInfo]) {
        let group = DispatchGroup()
        
        for food in foods {
            group.enter()
            
            PassioNutritionAI.shared.fetchFoodItemFor(foodItem: food.foodDataInfo) { (foodItem) in
                
                if let foodItem {
                    
                    var foodRecord = FoodRecordV3(foodItem: foodItem)
                    
                    if foodRecord.setSelectedUnit(unit: food.portionSize.separateStringUsingSpace.1 ?? "") {
                        let quantity = food.portionSize.separateStringUsingSpace.0 ?? "0"
                        foodRecord.setSelectedQuantity(quantity: Double(quantity) ?? 0)
                    } else {
                        if foodRecord.setSelectedUnit(unit: "gram") {
                            foodRecord.setSelectedQuantity(quantity: food.weightGrams)
                        }
                    }
                    foodRecord.mealLabel = MealLabel(mealTime: PassioMealTime.currentMealTime())
                    PassioInternalConnector.shared.updateRecord(foodRecord: foodRecord, isNew: true)
                    group.leave()
                } else {
                    group.leave()
                }
            }
        }
        
        
        
        
        group.notify(queue: .main) { [weak self] in
            let loggedFoods = foods.compactMap({
                $0.recognisedName
            }).joined(separator: "\n")
            let message = "Foods logged:\n\(loggedFoods)"
            append(NutritionAdvisorMessageDataSource(content: message, type: ., response: <#T##PassioAdvisorResponse?#>, images: <#T##[String]#>))
        }
    }
}
