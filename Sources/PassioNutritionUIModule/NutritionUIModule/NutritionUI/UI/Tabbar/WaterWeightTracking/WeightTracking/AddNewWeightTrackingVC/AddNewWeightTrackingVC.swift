//
//  AddNewWeightTrackingVC.swift
//  PassioNutritionUIModule
//
//  Created by Tushar S on 07/11/24.
//

import UIKit

protocol AddNewWeightTrackingDelegate {
    func refreshRecords()
}

class AddNewWeightTrackingVC: UIViewController {

    @IBOutlet weak var weightTitleLabel: UILabel!
    @IBOutlet weak var weightValueTextField: UITextField!
    @IBOutlet weak var dayTitleLabel: UILabel!
    @IBOutlet weak var dayValueTextField: UITextField!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var timeValueTextField: UITextField!
    @IBOutlet weak var buttonContainerStackViewBottomConst: NSLayoutConstraint!
    @IBOutlet var arrValueTextField: [UITextField]!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private var dateSelector: DateSelectorViewController?
    private var currentField: UITextField?
    private var selectedDate: Date?
    private var selectedTime: Date?
    private var userProfile: UserProfileModel!
    private var userEnteredWeight: Double?
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = DateFormatString.mmmm_dd_yyyy
        return df
    }()
    
    private let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = DateFormatString.h_mm_a
        return df
    }()
    
    var delegate:AddNewWeightTrackingDelegate?
    var isEditMode: Bool = false
    var weightRecord: WeightTracking!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfile = UserManager.shared.user ?? UserProfileModel()
        arrValueTextField.forEach {
            $0.configureTextField(leftPadding: 0)
                $0.autocorrectionType = .no
            $0.delegate = self
            $0.clearsOnBeginEditing = true
            $0.vwBorderWidth = 1
            $0.vwCornerRadius = 4
            $0.addOkButtonToToolbar(target: self,
                                    action: #selector(closeKeyBoard),
                                    forEvent: .touchUpInside)
            }
        if isEditMode {
            selectedDate = weightRecord.dateTime
            selectedTime = weightRecord.dateTime
            let value = userProfile.units == .imperial ? Double(weightRecord.weight * Conversion.lbsToKg.rawValue) : weightRecord.weight
            userEnteredWeight = value.roundDigits(afterDecimal: 1)
            weightValueTextField.text = "\(userEnteredWeight!.clean) \(userProfile.selectedWeightUnit)"
        }
        else {
            selectedDate = Date()
            selectedTime = Date()
        }
        
        dayValueTextField.text = dateFormatter.string(from: selectedDate!)
        timeValueTextField.text = timeFormatter.string(from: selectedTime!)
        
        self.registerForKeyboardNotifications()
        self.configureNavBar()
    }

    
    deinit {
        // Remove the observer when the view is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

extension AddNewWeightTrackingVC {

    @objc private func closeKeyBoard() {
        self.view.endEditing(true)
        arrValueTextField.forEach({
            $0.vwBorderColor = .gray300
        })
        currentField = nil
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)),name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(keyboardWillBeHide(_:)),name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        // Get the keyboard size from the notification's userInfo
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? CGRect.zero
        
        // Calculate how much space to move the button
        let keyboardHeight = keyboardFrame.height
        
        // Adjust the button's bottom constraint to move the button above the keyboard
        UIView.animate(withDuration: 0.25) {
            self.buttonContainerStackViewBottomConst.constant = keyboardHeight - 20.0 // Add some padding (20) to prevent the button being too close to the keyboard
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillBeHide(_ notification: Notification) {
        // Reset the button's bottom constraint to its original value
        UIView.animate(withDuration: 0.25) {
            self.buttonContainerStackViewBottomConst.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func configureNavBar() {
        
        self.title = "Weight Tracking"
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.updateStatusBarColor(color: .statusBarColor)
        
        setupBackButton()
        
    }
    
}


extension AddNewWeightTrackingVC: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if textField == weightValueTextField {
            if let _weight = textField.text,
               let dWeight = Int(_weight),
               dWeight > 0 {
                userEnteredWeight = Double(dWeight)
                textField.text = "\(dWeight) \(userProfile.selectedWeightUnit)"
            }
            else {
                if isEditMode {
                    let value = userProfile.units == .imperial ? (weightRecord.weight*Conversion.lbsToKg.rawValue).roundDigits(afterDecimal: 1) : weightRecord.weight
                    textField.text = "\(value.clean) \(userProfile.selectedWeightUnit)"
                }
                else {
                    textField.text = ""
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == weightValueTextField {
            dayValueTextField.vwBorderColor = .gray300
            timeValueTextField.vwBorderColor = .gray300
            weightValueTextField.vwBorderColor = .indigo700
        }
        
        return true
    }
    
}


// MARK: - DateSelectorUIView Delegate
extension AddNewWeightTrackingVC: DateSelectorUIViewDelegate {
    
    @objc func showDateSelector(pickerMode: UIDatePicker.Mode = .date) {
        dateSelector = DateSelectorViewController()
        dateSelector?.delegate = self
        dateSelector?.dateForPicker = Date()
        dateSelector?.datePickerType = pickerMode
        dateSelector?.isMaxDateSet = (pickerMode == .time && (selectedDate ?? Date()).isDateLessThanTodayIgnoringTime) ? false : true
        dateSelector?.modalPresentationStyle = .overFullScreen
        self.navigationController?.presentVC(vc: dateSelector!)
    }
    
    func removeDateSelector(remove: Bool) {
        dateSelector?.dismiss(animated: false)
    }
    
    func dateFromPicker(date: Date) {
        if let currentField = currentField {
            if currentField == dayValueTextField {
                dayValueTextField.text = dateFormatter.string(from: date)
                selectedDate = date
                if Date.isTodayDateWithFutureTime(date: selectedDate!, time: selectedTime!) {
                    timeValueTextField.text = timeFormatter.string(from: date)
                    selectedTime = date
                }
            }
            else if currentField == timeValueTextField {
                timeValueTextField.text = timeFormatter.string(from: date)
                selectedTime = date
            }
        }
        currentField = nil
    }
}
   
extension AddNewWeightTrackingVC {
    @IBAction func showDatePickerAction(_ sender: UIButton) {
        self.closeKeyBoard()
        self.showDateSelector(pickerMode: .date)
        currentField = self.dayValueTextField
        arrValueTextField.forEach({
            $0.vwBorderColor = .gray300
        })
        self.dayValueTextField.vwBorderColor = .indigo600
    }
    
    @IBAction func showTimePickerAction(_ sender: UIButton) {
        self.closeKeyBoard()
        self.showDateSelector(pickerMode: .time)
        currentField = self.timeValueTextField
        arrValueTextField.forEach({
            $0.vwBorderColor = .gray300
        })
        self.timeValueTextField.vwBorderColor = .indigo600
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        // This function is execute when keyboard is open and user directly press save button
        if self.buttonContainerStackViewBottomConst.constant != 0 {
            handleTextFieldActionOnSaveTapped()
        }
        
        if let fieldValue = weightValueTextField.text,
           fieldValue.count > 0,
           let roundedValue = userEnteredWeight,
           let selectedDate = selectedDate,
           let selectedTime = selectedTime {
            let value = userProfile.units == .imperial ? roundedValue/Conversion.lbsToKg.rawValue : roundedValue
            let recordDateTime = Date.combineTwoDate(dateToFetch: selectedDate, timeToFetch: selectedTime) ?? Date()
            var weightTrackModel = WeightTracking(weight: value, dateTime: recordDateTime)
            
            if isEditMode {
                weightTrackModel = WeightTracking(id: weightRecord.id, weight: value, dateTime: recordDateTime)
            }
            
            PassioInternalConnector.shared.updateWeightRecord(weightRecord: weightTrackModel) { bResult in
                if bResult {
                    self.delegate?.refreshRecords()
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func handleTextFieldActionOnSaveTapped() {
        if let textField = weightValueTextField,
           ((textField.text?.isEmpty) != nil) {
            if let _weight = textField.text,
               let dWeight = Int(_weight),
               dWeight > 0 {
                userEnteredWeight = Double(dWeight)
                weightValueTextField.text = "\(dWeight) \(userProfile.selectedWeightUnit)"
            }
            else {
                if isEditMode {
                    let value = userProfile.units == .imperial ? (weightRecord.weight*Conversion.lbsToKg.rawValue).roundDigits(afterDecimal: 1) : weightRecord.weight
                    weightValueTextField.text = "\(value.clean) \(userProfile.selectedWeightUnit)"
                }
                else {
                    weightValueTextField.text = ""
                }
            }
        }
    }
}
