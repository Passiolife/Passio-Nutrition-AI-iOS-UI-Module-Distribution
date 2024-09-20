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
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createFooterView()
    }
    
    private func setupUI() {
        title = "Nutrition Advisor"
        setupBackButton()
        hideKeyboardWhenTappedAround()
        imagePicker = ImagePicker()
    }
    
    private func createFooterView() {
        if footerView == nil {
            let footer = AnalyzingView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            footerView = footer
        }
    }
    
    private func showFooterView() {
        if let footerView = footerView {
            tableView.tableFooterView = footerView
        }
    }
    
    private func hideFooterView() {
        tableView.tableFooterView = nil
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
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    private func headerFooterHeight(for type: MeassageType?) -> CGFloat {
        let height = (type == .receivedFood) ? UITableView.automaticDimension : .leastNonzeroMagnitude
        return height
    }
}

// MARK: - Helper

extension NutritionAdvisorVC
{
    func showWelcomeMessage() {
        guard datasource.isEmpty else { return }
        let naMessage = NAMessage(threadId: "", messageId: "", content: NAWelcomeMessage)
        let response = PassioAdvisorResponse(message: naMessage)
        let message = NAMessageModel(response: response, type: .receivedMessage)
        append(message)
        //----------------------------//
        //var message2 = NAMessageModel(response: nil, type: .receivedFood)
        //append(message2)
    }
    
    private func append(_ message: NAMessageModel) {
        datasource.append(message)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] () in
            guard let self else { return }
            let indexPath = IndexPath(row: NSNotFound, section: datasource.count - 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @IBAction func sendTextTapped() {
        let message = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isReady, message != "" else { return }
        append(NAMessageModel(content: message))
        sendMessage(message: message)
        clearTextView()
    }
    
    @IBAction func pickImageTapped() {
        //openCamera()
        openGallary()
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
        ProgressHUD.show(presentingVC: self)
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            NutritionAdvisor.shared.delegate = self
            NutritionAdvisor.shared.initConversation { advisorResult in
                ProgressHUD.hide(presentedVC: self)
                DispatchQueue.main.async {
                    switch advisorResult {
                    case .success:
                        self.showWelcomeMessage()
                        self.isReady = true
                    case .failure(let error):
                        self.showAlertForError(alertTitle: error.errorMessage)
                    }
                }
            }
        }
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
    
    func sendImage(image: UIImage) {
        showFooterView()
        NutritionAdvisor.shared.sendImage(image: image) { [weak self] advisorResponse in
            guard let self else { return }
            DispatchQueue.main.async {
                self.hideFooterView()
                switch advisorResponse {
                case .success(let response):
                    self.append(NAMessageModel(response: response, type: .receivedFood, isImageResult: true))
                case .failure(let error):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.showAlertForError(alertTitle: error.errorMessage)
                    }
                }
            }
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
                    print("Count of food: \(response.extractedIngredients?.count)")
                    if (response.extractedIngredients?.count ?? 0) > 0 {
                        self.append(NAMessageModel(response: response, type: .receivedFood))
                    }
                case .failure(let error):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.showAlertForError(alertTitle: error.errorMessage)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension NutritionAdvisorVC: UITableViewDataSource, UITableViewDelegate
{
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
            headerView.load(title: message.isImageResult ? NAImageSearchTitle: NATextSearchTitle)
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
            footerView.load()
            footerView.actionButtonTap = { [weak self] sender in
                print("Section: \(section)")
            }
            return footerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let message = datasource[section]
        return (message.type == .receivedFood) ? message.foodCount : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = datasource[indexPath.section]
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
            let advisorFoodInfo = message.response?.extractedIngredients?[indexPath.row]
            cell.load(advisorInfo: advisorFoodInfo)
            cell.radioButtonTap = { [weak self] sender in
                cell.radioButton.isSelected.toggle()
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - ImagePickerDelegate

extension NutritionAdvisorVC: ImagePickerDelegate {
    func didSelect(images: [UIImage]) {
        var message = NAMessageModel(images: images)
        self.append(message)
    }
}

// MARK: - UITextViewDelegate

extension NutritionAdvisorVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let esmitated = CGSize(width: textView.frame.width, height: .infinity)
        let esmitatedSize = textView.sizeThatFits(esmitated)
        textViewHeightConstraint.constant = esmitatedSize.height
    }
}

extension NutritionAdvisorVC: UsePhotosDelegate {
    func onSelecting(images: [UIImage]) {
        if images.count < 1 { return }
        var message = NAMessageModel(images: images)
        append(message)
    }
}

extension NutritionAdvisorVC: NutritionAdvisorDelegate 
{
    func requestedDataForMessage(message: PassioNutritionUIModule.PassioAdvisorResponse) -> String?
    {
//        guard let dataRequest = message.dataRequest,
//              dataRequest.name == "DetectMealLogsRequired"
//        else { return nil }
//        return PassioExternalConnector.shared.fetchMealLogsJson(daysBack: dataRequest.daysBack)
        return "testing"
    }
}
