//
//  AddNewWaterTrackingVC.swift
//  
//
//  Created by Mindinventory on 13/11/24.
//

import UIKit

protocol AddNewWaterTrackingDelegate {
    func refreshRecords()
}

class AddNewWaterTrackingVC: UIViewController {

    @IBOutlet weak var waterTitleLabel: UILabel!
    @IBOutlet weak var waterValueTextField: UITextField!
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
    private var userEnteredWater: Double?
    private var userProfileWaterUnit: WaterUnit = .oz
    
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
    
    var delegate:AddNewWaterTrackingDelegate?
    var isEditMode: Bool = false
    var waterRecord: WaterTracking!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfile = UserManager.shared.user ?? UserProfileModel()
        userProfileWaterUnit = userProfile.waterUnit ?? .oz
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
            selectedDate = waterRecord.dateTime
            selectedTime = waterRecord.dateTime
            let value = waterRecord.water
            userEnteredWater = value.roundDigits(afterDecimal: 1)
            waterValueTextField.text = "\(userEnteredWater!.clean) \(userProfileWaterUnit)"
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

extension AddNewWaterTrackingVC {

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
        
        self.title = "Water Tracking"
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.updateStatusBarColor(color: .statusBarColor)
        
        setupBackButton()
        
    }
    
}


extension AddNewWaterTrackingVC: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if textField == waterValueTextField {
            if let _water = textField.text,
               let dWater = Int(_water),
               dWater > 0 {
                userEnteredWater = Double(dWater)
                textField.text = "\(dWater) \(userProfileWaterUnit)"
            }
            else {
                if isEditMode {
                    let value = waterRecord.water
                    textField.text = "\(value.clean) \(userProfileWaterUnit)"
                }
                else {
                    textField.text = ""
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == waterValueTextField {
            dayValueTextField.vwBorderColor = .gray300
            timeValueTextField.vwBorderColor = .gray300
            waterValueTextField.vwBorderColor = .indigo700
        }
        
        return true
    }
    
}


// MARK: - DateSelectorUIView Delegate
extension AddNewWaterTrackingVC: DateSelectorUIViewDelegate {
    
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
        arrValueTextField.forEach({
            $0.vwBorderColor = .gray300
        })
    }
}
   
extension AddNewWaterTrackingVC {
    @IBAction func showDatePickerAction(_ sender: UIButton) {
        self.closeKeyBoard()
        self.showDateSelector(pickerMode: .date)
        currentField = self.dayValueTextField
        arrValueTextField.forEach({
            $0.vwBorderColor = .gray300
        })
        dayValueTextField.vwBorderColor = .indigo700
    }
    
    @IBAction func showTimePickerAction(_ sender: UIButton) {
        self.closeKeyBoard()
        self.showDateSelector(pickerMode: .time)
        currentField = self.timeValueTextField
        arrValueTextField.forEach({
            $0.vwBorderColor = .gray300
        })
        timeValueTextField.vwBorderColor = .indigo700
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        // This function is execute when keyboard is open and user directly press save button
        if self.buttonContainerStackViewBottomConst.constant != 0 {
            handleTextFieldActionOnSaveTapped()
        }
        
        if let fieldValue = waterValueTextField.text,
           fieldValue.count > 0,
           let roundedValue = userEnteredWater,
           let selectedDate = selectedDate,
           let selectedTime = selectedTime {
            let value = roundedValue
            let recordDateTime = Date.combineTwoDate(dateToFetch: selectedDate, timeToFetch: selectedTime) ?? Date()
            var waterTrackModel = WaterTracking(water: value, dateTime: recordDateTime)
            
            if isEditMode {
                waterTrackModel = WaterTracking(id: waterRecord.id, water: value, dateTime: recordDateTime)
            }
            
            NutritionUIModule.shared.updateWaterRecord(waterRecord: waterTrackModel) { bResult in
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
        if let textField = waterValueTextField,
           ((textField.text?.isEmpty) != nil) {
            if let _water = textField.text,
               let dWater = Int(_water),
               dWater > 0 {
                userEnteredWater = Double(dWater)
                waterValueTextField.text = "\(dWater) \(userProfileWaterUnit)"
            }
            else {
                if isEditMode {
                    let value = waterRecord.water
                    waterValueTextField.text = "\(value.clean) \(userProfileWaterUnit)"
                }
                else {
                    waterValueTextField.text = ""
                }
            }
        }
    }
}
