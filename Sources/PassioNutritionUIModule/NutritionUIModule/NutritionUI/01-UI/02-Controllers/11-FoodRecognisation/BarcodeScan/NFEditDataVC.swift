//
//  NFEditDataVC.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 23/05/25.
//

import UIKit

class NFEditDataVC: UIViewController {
    
    @IBOutlet weak var parentView: UIView!

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameTf: PassioTF!
    @IBOutlet weak var barcodeTf: PassioTF!

    @IBOutlet weak var caloriesView: NFInputView!
    @IBOutlet weak var carbsView: NFInputView!
    @IBOutlet weak var proteinView: NFInputView!
    @IBOutlet weak var fatView: NFInputView!
    
    @IBOutlet weak var servingView: NFInputView!
    @IBOutlet weak var unitTf: PassioTF!
    @IBOutlet weak var weightView: NFInputView!
    
    @IBOutlet weak var unitButton: UIButton!

    var caloriesTf: UITextField { caloriesView.textField }
    var carbsTf: UITextField { carbsView.textField }
    var proteinTf: UITextField { proteinView.textField }
    var fatTf: UITextField { fatView.textField }
    var servingTf: UITextField { servingView.textField }
    var weightTf: UITextField { weightView.textField }
    
    private let connector = NutritionUIModule.shared
    var capturedImage: UIImage?
    var foodRecord: FoodRecordV3?
    var dataSet: NutritionFactsDataSet?
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?

    var isUnitGramOrMl: Bool {
        isGramsOrMl(unit: unitTf.text ?? "")
    }
    
    /**
     If no Nutrition facts found from previous
     screen, user can enter data manually
     */
    var isEnterManually: Bool = false
    
    /** Used when back from Barcode recogniser */
    private var isEditExisting: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        registerForKeyboardNotifications()
        setData()
    }
    
    func basicSetup() {
        self.view.backgroundColor = UIColor.black.alpha(0.8)
        
        nameTf.delegate = self
        nameTf.tag = InputType.foodName.rawValue
        
        barcodeTf.delegate = self
        barcodeTf.tag = InputType.barcode.rawValue
        barcodeTf.rightImage = UIImage.imageFromBundle(named: "barcodeScanSmall")

        unitTf.delegate = self
        unitTf.tag = InputType.servingUnit.rawValue

        caloriesView.configure(title: "Calories", unit: "cal", tag: InputType.calories.rawValue, tfDelegate: self, doneDelegate: self)
        carbsView.configure(title: "Carbs", unit: "g", tag: InputType.carbs.rawValue, tfDelegate: self, doneDelegate: self)
        proteinView.configure(title: "Protein", unit: "g", tag: InputType.protein.rawValue, tfDelegate: self, doneDelegate: self)
        fatView.configure(title: "Fat", unit: "g", tag: InputType.fat.rawValue, tfDelegate: self, doneDelegate: self)
        servingView.configure(title: "Serving", tag: InputType.servingSize.rawValue, tfDelegate: self, doneDelegate: self)
        weightView.configure(title: "Weight", unit: "g", tag: InputType.weight.rawValue, tfDelegate: self, doneDelegate: self)
        
        [nameTf, barcodeTf, caloriesTf, carbsTf, proteinTf, fatTf, servingTf, unitTf, weightTf].forEach { textfield in
            textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        setupDropDown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupDropDown() {
        let actionClosure = { [weak self] (action: UIAction) in
            guard let self else { return }
            guard unitsArray.firstIndex(where: { $0 == action.title }) != nil else { return }
            unitTf.text = action.title
            updateWeightTextField()
        }
        let menuChildren = unitsArray.map { unit in
            UIAction(title: unit, handler: actionClosure)
        }
        unitButton.menu = UIMenu(title: "Unit", children: menuChildren)
        unitButton.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.onCancel?()
        }
    }
    
    private func navigateToBarcodeRecogniser() {
        let vc = RecogniseBarcodeVC.load(storyboard: .SCAN)
        vc.barcodeDelegate = self
        self.push(vc)
    }
    
    func updateWeightTextField() {
        if isUnitGramOrMl {
            weightView.isHidden = true
            weightTf.text = ""
        } else {
            weightView.isHidden = false
        }
    }
}

extension NFEditDataVC {
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if !validateField(for: .foodName) { return }
        if !validateField(for: .calories) { return }
        if !validateField(for: .carbs) { return }
        if !validateField(for: .protein) { return }
        if !validateField(for: .fat) { return }
        if !validateField(for: .servingSize) { return }
        if !validateField(for: .servingUnit) { return }
        if !isUnitGramOrMl {
            if !validateField(for: .weight) { return }
        }
        saveData()
    }
    
    private var createDataSet: NutritionFactsDataSet {
        return NutritionFactsDataSet(nutritionFacts: foodRecord?.getNutritionFacts ?? PassioNutritionFacts())
    }
    
    private var emptyDataSet: NutritionFactsDataSet {
        return NutritionFactsDataSet(nutritionFacts: PassioNutritionFacts())
    }
    
    func setData() {
        if let image = capturedImage {
            let thumbnail = resizeImage(image, to: CGSize(width: 100, height: 100))
            foodImageView.image = thumbnail
        }
        nameTf.text = foodRecord?.name ?? ""
        barcodeTf.text = foodRecord?.barcode ?? ""
        
        /** Create dataset and set nutrients */
        if isEnterManually {
            self.dataSet = self.emptyDataSet
        } else {
            self.dataSet = self.createDataSet
        }
        setNutrients()
    }
    
    func setDataFromSystemFood(barcode: String, foodRecord: FoodRecordV3?, isImportData: Bool) {
        
        self.isEditExisting = false
        self.foodRecord = foodRecord
        
        if isImportData {
            nameTf.text = foodRecord?.name ?? ""
            barcodeTf.text = foodRecord?.barcode ?? ""
            self.dataSet = self.createDataSet
            setNutrients()
        } else {
            barcodeTf.text = barcode
        }
    }
    
    func setDataFromCustomFood(barcode: String, foodRecord: FoodRecordV3?, isEditExisting: Bool) {
        
        self.isEditExisting = isEditExisting
        self.foodRecord = foodRecord

        nameTf.text = foodRecord?.name ?? ""
        if isEditExisting {
            barcodeTf.text = foodRecord?.barcode ?? ""
        }
        self.dataSet = self.createDataSet
        setNutrients()
    }
    
    func setNutrients() {
        guard let dataSet = self.dataSet else { return }
        
        caloriesTf.text = (dataSet.calories?.value?.roundDigits(afterDecimal: 2).clean ?? "")
        carbsTf.text = (dataSet.carbs?.value?.roundDigits(afterDecimal: 2).clean ?? "")
        proteinTf.text = (dataSet.protein?.value?.roundDigits(afterDecimal: 2).clean ?? "")
        fatTf.text = (dataSet.fat?.value?.roundDigits(afterDecimal: 2).clean ?? "")
        
        servingTf.text = (dataSet.nutritionFacts?.servingSizeQuantity.roundDigits(afterDecimal: 2).clean ?? "")
        unitTf.text = (dataSet.nutritionFacts?.servingSizeUnitName?.capitalized ?? "")
        weightTf.text = (dataSet.nutritionFacts?.servingSizeGram?.roundDigits(afterDecimal: 2).clean ?? "")
        
        updateWeightTextField()
    }
    
    func saveData() {
        
        // Image, Name, Barcode
        let foodImage = capturedImage?.get180pImage ?? UIImage()
        let foodName = nameTf.text ?? ""
        let barcode = barcodeTf.text ?? ""
        
        // Update dataset
        if let servings = servingTf.text?.clear.double {
            dataSet?.nutritionFacts?.servingSizeQuantity = servings
        }
        if let unit = unitTf.text?.clear {
            dataSet?.nutritionFacts?.servingSizeUnitName = unit
        }
        if let calories = caloriesTf.text?.clear.double {
            dataSet?.nutritionFacts?.calories = calories
        }
        if let carbs = carbsTf.text?.clear.double {
            dataSet?.nutritionFacts?.carbs = carbs
        }
        if let protein = proteinTf.text?.clear.double {
            dataSet?.nutritionFacts?.protein = protein
        }
        if let fat = fatTf.text?.clear.double {
            dataSet?.nutritionFacts?.fat = fat
        }
        if isUnitGramOrMl {
            if let servings = servingTf.text?.clear.double {
                dataSet?.nutritionFacts?.servingSizeGram = servings
            }
        } else {
            if let weight = weightTf.text?.clear.double {
                dataSet?.nutritionFacts?.servingSizeGram = weight
            }
        }
        
        // Create food record
        guard let foodItem = dataSet?.nutritionFacts?.fromNutritionFacts(foodName: foodName) else { return }
        
        var record = FoodRecordV3(foodItem: foodItem, barcode: barcode, entityType: .nutritionFacts)
        record.iconId = record.iconId.contains("userFood") ? record.iconId : "userFood.\(record.iconId).\(record.createdAt)"
        record.refCode = record.refCode.contains("userFood") ? record.refCode : "userFood.\(record.refCode)"
        record.mealLabel = .mealLabelBy()
        
        if isEditExisting, let foodRecord = self.foodRecord {
            record.uuid = foodRecord.uuid
        }
        
        // Add user food
        connector.updateUserFood(record: record)
        connector.updateUserFoodImage(with: record.iconId, image: foodImage)
        
        // Log record
        connector.updateRecord(foodRecord: record)
        
        // Dismiss
        self.dismiss(animated: true) {
            self.onSave?()
        }
    }
}

extension NFEditDataVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let type: InputType = InputType(value: textField.tag)
        switch type {
        case .servingUnit:
            return false
        case .barcode:
            navigateToBarcodeRecogniser()
            return false
        default:
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let type: InputType = InputType(value: textField.tag)
        switch type {
        case .foodName:
            return true
        case .barcode:
            return true
        case .calories, .carbs, .protein, .fat, .servingSize, .weight:
            let currentText = textField.text ?? ""
            return isValidDecimalInput(currentText: currentText, range: range, replacementString: string)
        case .servingUnit:
            return true
        case .other:
            return true
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let type: InputType = InputType(value: textField.tag)
        validateField(for: type)
    }
    
    private func isGramsOrMl(unit: String) -> Bool {
        let unitLowercased = unit.lowercased()
        let result = unitLowercased == "\(UnitsTexts.gram)" || unitLowercased == "\(UnitsTexts.grams)" || unitLowercased == "\(UnitsTexts.ml)"
        return result
    }
    
    @discardableResult
    func validateField(for type: InputType) -> Bool {
        switch type {
        case .foodName:
            let isValid = !(nameTf.text?.clear.isEmpty ?? true)
            nameTf.setValid(isValid)
            return !(nameTf.text?.clear.isEmpty ?? true)
        case .barcode:
            return true
        case .calories:
            let isValid = isValidDecimal(caloriesTf.text)
            caloriesView.setValid(isValid)
            return isValid
        case .carbs:
            let isValid = isValidDecimal(carbsTf.text)
            carbsView.setValid(isValid)
            return isValid
        case .protein:
            let isValid = isValidDecimal(proteinTf.text)
            proteinView.setValid(isValid)
            return isValid
        case .fat:
            let isValid =  isValidDecimal(fatTf.text)
            fatView.setValid(isValid)
            return isValid
        case .servingSize:
            let isValid = isValidDecimal(servingTf.text)
            servingView.setValid(isValid)
            return isValid
        case .servingUnit:
            let isValid = !(unitTf.text?.clear.isEmpty ?? true)
            unitTf.setValid(isValid)
            return isValid
        case .weight:
            let isValid = isValidDecimal(weightTf.text)
            weightView.setValid(isValid)
            return isValid
        case .other:
            return true
        }
    }
}

extension NFEditDataVC: DoneButtonDelegate {
    func doneTapped() {
        print("done tapped")
    }
}

extension NFEditDataVC: RecogniseBarcodeDelegate {
    
    func detectedBarcode(barcode: String) {
        self.isEditExisting = false
        barcodeTf.text = barcode
    }
    func detectedSystemFood(barcode: String, foodRecord: FoodRecordV3?, isImportData: Bool) {
        setDataFromSystemFood(barcode: barcode, foodRecord:foodRecord, isImportData: isImportData)
    }
    func detectedCustomFood(barcode: String, foodRecord: FoodRecordV3?, isEditExisting: Bool) {
        setDataFromCustomFood(barcode: barcode, foodRecord:foodRecord, isEditExisting: isEditExisting)
    }
}

extension NFEditDataVC {
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            UIView.animate(withDuration: 0.3) {
                self.parentView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.parentView.transform = .identity
        }
    }
}
