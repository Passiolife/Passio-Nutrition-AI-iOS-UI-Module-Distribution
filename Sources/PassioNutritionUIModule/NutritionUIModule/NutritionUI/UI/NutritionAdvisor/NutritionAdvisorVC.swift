//
//  NutritionAdvisorVC.swift
//  
//
//  Created by Pratik on 16/09/24.
//

import Foundation
import UIKit
import PassioNutritionUIModule
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class NutritionAdvisorVC: InstantiableViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var imagePickerButton: UIButton!
    @IBOutlet weak var imageCaptureButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    private var isReady: Bool = false
    private var datasource: [NAMessageModel] = []
    private var keyboardHeight: CGFloat = 0
    private var footerView: AnalyzingView?
    private var imagePicker: ImagePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTable()
        setupAdvisor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
        createFooterView()
    }
    
    deinit {
        guard datasource.count > 1 else { return }
        PassioUserDefaults.saveAdvisorHistory(datasource)
    }
    
    private func setupUI() {
        title = NAScreenTitle
        setupBackButton()
        hideKeyboardWhenTappedAround()
        imagePicker = ImagePicker()
        updateImageControls(showOptions: false)
        
        textView.minHeight = 36
        textView.maxHeight = 100
        textView.placeholder = NATextViewPlaceholder
        textView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
    }
    
    private func setupTable() {
        NAChatCellType.allCases.forEach {
            tableView.register(nibName: $0.rawValue)
        }
        tableView.registerHeaderFooter(NAItemsHeader.self)
        tableView.registerHeaderFooter(NAItemsFooter.self)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 36
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 36
    }
    
    private func createFooterView() {
        if footerView == nil {
            let footer = AnalyzingView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            footerView = footer
        }
    }
    
    private func showFooterView(isAnalysing: Bool = false) {
        if let footerView = footerView {
            footerView.updateUI(isAnalysing)
            tableView.tableFooterView = footerView
        }
        scrollToBottom()
        enableInteration(false)
    }
    
    private func hideFooterView() {
        tableView.tableFooterView = nil
        enableInteration(true)
    }
    
    func enableInteration(_ isEnable: Bool) {
        controlsContainer.isUserInteractionEnabled = isEnable
        controlsContainer.alpha = isEnable ? 1 : 0.5
        //tableView.isUserInteractionEnabled = isEnable
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
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
    }
    
    private func headerFooterHeight(for type: MeassageType?) -> CGFloat {
        let height = (type == .receivedFood) ? UITableView.automaticDimension : .leastNonzeroMagnitude
        return height
    }
    
    @IBAction func plusButtonTapped() {
        updateImageControls(showOptions: true)
    }
    
    @IBAction func imagePickerButtonTapped() {
        openGallary()
    }
    
    @IBAction func imageCaptureButtonTapped() {
        openCamera()
    }
    
    @IBAction func closeButtonTapped() {
        updateImageControls(showOptions: false)
    }
    
    func updateImageControls(showOptions: Bool) {
        plusButton.isHidden = showOptions
        imagePickerButton.isHidden = !showOptions
        imageCaptureButton.isHidden = !showOptions
        closeButton.isHidden = !showOptions
    }
    
    func navigateToDairy() {
        NutritionUICoordinator.navigateToDairyAfterAction(navigationController: navigationController)
    }
}

// MARK: - Helper

extension NutritionAdvisorVC {
    
    private func append(_ message: NAMessageModel) {
        datasource.append(message)
        reloadTable()
    }
    
    func reloadTable() {
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] () in
            guard let self else { return }
            let indexPath = IndexPath(row: NSNotFound, section: datasource.count - 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func scrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] () in
            guard let self else { return }
            let y = tableView.contentSize.height - tableView.frame.size.height
            if y < 0 { return }
            tableView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
    
    @IBAction func sendTextTapped() {
        let message = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isReady, message != "" else { return }
        append(NAMessageModel(content: message))
        sendMessage(message: message)
        clearTextView()
    }
    
    func openGallary() {
        guard let imagePicker = imagePicker else { return }
        imagePicker.delegate = self
        imagePicker.present(on: self)
    }
    
    func openCamera() {
        let imageCapture = ImageCapture()
        imageCapture.delegate = self
        navigationController?.pushViewController(imageCapture, animated: true)
    }
}

// MARK: - NutritionAdvisor

extension NutritionAdvisorVC {
    
    func setupAdvisor() {
        ProgressHUD.show(presentingVC: self, color: .gray500)
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            NutritionAdvisor.shared.initConversation { advisorResult in
                ProgressHUD.hide(presentedVC: self)
                DispatchQueue.main.async {
                    switch advisorResult {
                    case .success:
                        self.isReady = true
                        self.startAdvisor()
                    case .failure(let error):
                        self.showAlertForError(alertTitle: error.errorMessage)
                    }
                }
            }
        }
    }
    
    func startAdvisor() {
        if let history = PassioUserDefaults.fetchAdvisorHistory() {
            datasource = history
            reloadTable()
        } else {
            showWelcomeMessage()
        }
    }
    
    func showWelcomeMessage() {
        guard datasource.isEmpty else { return }
        let naMessage = NAMessage(threadId: "", messageId: "", content: NAWelcomeMessage)
        let response = PassioAdvisorResponse(message: naMessage)
        let message = NAMessageModel(response: response, type: .receivedMessage)
        append(message)
    }
    
    func sendMessage(message: String) {
        showFooterView()
        NutritionAdvisor.shared.sendMessage(message: message) { [weak self] advisorResponse in
            guard let self else { return }
            DispatchQueue.main.async {
                self.hideFooterView()
                switch advisorResponse {
                case .success(let response):
                    self.append(NAMessageModel(response: response, type: .receivedMessage))
                case .failure(let error):
                    self.showAlertForError(alertTitle: error.errorMessage)
                }
            }
        }
    }
    
    func didSelectImages(_ images: [UIImage]) {
        guard isReady else { return }
        if images.count < 1 { return }
        append(NAMessageModel(images: images))
        sendImages(images: images)
    }
    
    func sendImages(images: [UIImage]) {
        
        let group = DispatchGroup()
        var foodItems = [NAFoodItem]()
        showFooterView(isAnalysing: true)
        
        for image in images {
            group.enter()
            NutritionAdvisor.shared.sendImage(image: image) { [weak self] advisorResponse in
                guard let self else {
                    group.leave()
                    return
                }
                switch advisorResponse {
                case .success(let response):
                    guard let foodInfo = response.extractedIngredients, foodInfo.count > 0 else { return }
                    let foods = foodInfo.compactMap { NAFoodItem(food: $0) }
                    foodItems.append(contentsOf: foods)
                    group.leave()
                case .failure(let error):
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.hideFooterView()
            if foodItems.count < 1 {
                self.showAlertForError(alertTitle: NANoFoodItemRecognized)
                return
            }
            /** We are ignoring `response` in case of multiple result. **/
            self.append(NAMessageModel(foodItems: foodItems, isImageResult: true))
        }
    }
    
    func findFood(for message: NAMessageModel) {
        guard let response = message.response else { return }
        showFooterView()
        NutritionAdvisor.shared.fetchIngridients(from: response) { [weak self] advisorResponse in
            guard let self else { return }
            DispatchQueue.main.async {
                self.hideFooterView()
                switch advisorResponse {
                case .success(let response):
                    guard let foodInfo = response.extractedIngredients, foodInfo.count > 0 else { 
                        return
                    }
                    let foodItems = foodInfo.compactMap { NAFoodItem(food: $0) }
                    self.append(NAMessageModel(foodItems: foodItems, response: response))
                case .failure(let error):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.showAlertForError(alertTitle: error.errorMessage)
                    }
                }
            }
        }
    }
    
    func logFood(atIndex index: Int) {
        enableInteration(false)
        var message = datasource[index]
        let foodItems = message.foodItems.filter { $0.isSelected }
        
        var loggedFoodItems = [NAFoodItem]()
        let dispatchGroup = DispatchGroup()

        foodItems.forEach { foodItem in
            dispatchGroup.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                
                if let foodDataInfo = foodItem.food.foodDataInfo {
                    
                    PassioNutritionAI.shared.fetchFoodItemFor(
                        foodDataInfo: foodDataInfo,
                        servingQuantity: foodDataInfo.nutritionPreview?.servingQuantity,
                        servingUnit: foodDataInfo.nutritionPreview?.servingUnit
                    ) { passioFoodItem in
                        
                        if let passioFoodItem {
                            var foodRecord = FoodRecordV3(foodItem: passioFoodItem)
                            foodRecord.mealLabel = MealLabel(mealTime: PassioMealTime.currentMealTime())
                            PassioInternalConnector.shared.updateRecord(foodRecord: foodRecord)
                            loggedFoodItems.append(foodItem)
                            dispatchGroup.leave()
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            message.logStatus = .logged
            message.foodItems = loggedFoodItems
            self.tableView.reloadSections([index], with: .none)
            self.enableInteration(true)
        }
    }
}

// MARK: - UITableViewDataSource

extension NutritionAdvisorVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let message = datasource[section]
        return headerFooterHeight(for: message.type)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let message = datasource[section]
        if message.type == .receivedFood {
            let headerView = tableView.dequeueHeaderFooter(NAItemsHeader.self)
            headerView.configure(isImageResult: message.isImageResult, logStatus: message.logStatus)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let message = datasource[section]
        return headerFooterHeight(for: message.type)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let message = datasource[section]
        if message.type == .receivedFood {
            let footerView = tableView.dequeueHeaderFooter(NAItemsFooter.self)
            footerView.configure(logStatus: message.logStatus)
            footerView.actionButtonTap = { [weak self] sender in
                guard let self else { return }
                if message.logStatus == .logged {
                    self.navigateToDairy()
                } else {
                    let count = message.foodItems.filter { $0.isSelected }.count
                    if count < 1 {
                        self.showAlertForError(alertTitle: NANoFoodItemSelected)
                        return
                    }
                    message.logStatus = .logging
                    footerView.configure(logStatus: message.logStatus)
                    self.logFood(atIndex: section)
                }
            }
            return footerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let message = datasource[section]
        return (message.type == .receivedFood) ? message.foodItems.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var message = datasource[indexPath.section]
        switch message.type
        {
        case .sendMessage:
            let cell = tableView.dequeueCell(cellClass: SentTextCell.self, forIndexPath: indexPath)
            cell.load(message: message)
            return cell
            
        case .sendSingleImage:
            let cell = tableView.dequeueCell(cellClass: NASingleImageCell.self, forIndexPath: indexPath)
            cell.load(message: message)
            return cell
            
        case .sendMultiImage:
            let cell = tableView.dequeueCell(cellClass: NAMultiImageCell.self, forIndexPath: indexPath)
            cell.load(message: message)
            return cell
            
        case .receivedMessage:
            let cell = tableView.dequeueCell(cellClass: ReceivedTextCell.self, forIndexPath: indexPath)
            cell.load(message: message)
            cell.findFoodButtonTap = { [weak self] sender in
                guard let self = self else { return }
                findFood(for: message)
            }
            return cell
            
        case .receivedFood:
            let cell = tableView.dequeueCell(cellClass: NAFoodItemCell.self, forIndexPath: indexPath)
            cell.load(foodItem: message.foodItems[indexPath.row], logStatus: message.logStatus)
            cell.radioButtonTap = { [weak self] sender in
                message.foodItems[indexPath.row].isSelected.toggle()
                cell.updateRadioButton(isSelected: message.foodItems[indexPath.row].isSelected)
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - ImagePickerDelegate
// Gallery
extension NutritionAdvisorVC: ImagePickerDelegate {
    func didSelect(images: [UIImage]) {
        didSelectImages(images)
    }
}
// Camera
extension NutritionAdvisorVC: UsePhotosDelegate {
    func onSelecting(images: [UIImage]) {
        didSelectImages(images)
    }
}

extension NutritionAdvisorVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateImageControls(showOptions: false)
    }
}
