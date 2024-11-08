//
//  AddNewWeightTrackingVC.swift
//  PassioNutritionUIModule
//
//  Created by Tushar S on 07/11/24.
//

import UIKit

class AddNewWeightTrackingVC: UIViewController {

    @IBOutlet weak var weightTitleLabel: UILabel!
    @IBOutlet weak var weightValueTextField: UITextField!
    @IBOutlet weak var dayTitleLabel: UILabel!
    @IBOutlet weak var dayValueTextField: UITextField!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var timeValueTextField: UITextField!
    @IBOutlet weak var buttonContainerStackViewBottomConst: NSLayoutConstraint!
    @IBOutlet var arrValueTextField: [UITextField]!
    
    private var dateSelector: DateSelectorViewController?
    private var currentField: UITextField?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.dayValueTextField.addTarget(self, action: #selector(showDateSelector), for: .touchUpInside)
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        arrValueTextField.forEach({
            $0.vwBorderColor = .gray300
        })
        currentField = nil
        if (textField == dayValueTextField) || (textField == timeValueTextField){
            currentField = textField
        }
        textField.vwBorderColor = .indigo600
    }
}


// MARK: - DateSelectorUIView Delegate
extension AddNewWeightTrackingVC: DateSelectorUIViewDelegate {
    
    @objc func showDateSelector() {
        dateSelector = DateSelectorViewController()
        dateSelector?.delegate = self
        dateSelector?.dateForPicker = Date()
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
            }
            else if currentField == timeValueTextField {
                timeValueTextField.text = timeFormatter.string(from: date)
            }
        }
    }
}
   
