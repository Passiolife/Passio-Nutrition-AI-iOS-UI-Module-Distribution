//
//  PickerMacrosViewController.swift
//  BaseApp
//
//  Created by Mind on 04/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit

protocol PickerMacroViewDelegate: AnyObject {
    func pickerSelected(modelMacros: Macros?)
}

class PickerMacrosViewController: UIViewController {

    @IBOutlet weak var caloriesValueTextField  : UITextField!
    @IBOutlet weak var carbsValueLabel     : UILabel!
    @IBOutlet weak var proteinValueLabel   : UILabel!
    @IBOutlet weak var fatValueLabel       : UILabel!
    @IBOutlet weak var carbsPercentTextField   : UITextField!
    @IBOutlet weak var proteinPercentTextField : UITextField!
    @IBOutlet weak var fatPercentTextField     : UITextField!
    @IBOutlet weak var carbsSlider         : UISlider!
    @IBOutlet weak var proteinSlider       : UISlider!
    @IBOutlet weak var fatSlider           : UISlider!

    var modelMacros = Macros(caloriesTarget: 2100, carbsPercent: 0, proteinPercent: 0, fatPercent: 0)
    weak var delegate: PickerMacroViewDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUIToMatchMacros()
    }

    private func setupUI() {
        caloriesValueTextField.addOkButtonToToolbar(target: self,
                                                    action: #selector(closeKeyBoard),
                                                    forEvent: .touchUpInside)

        [carbsPercentTextField,proteinPercentTextField,fatPercentTextField].forEach { textField in
            textField?.delegate = self
            textField?.textAlignment = .right
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
            let unitLabel = UILabel(frame: CGRect(x: 2, y: 0, width: 18, height: 20))
            unitLabel.text = "%" // Set the unit symbol
            unitLabel.textAlignment = .left
            if let font = textField?.font{
                unitLabel.font = font
            }
            rightView.addSubview(unitLabel)
            // Set the label as the right view of the text field
            textField?.rightView = rightView
            textField?.rightViewMode = .always
            textField?.addOkButtonToToolbar(target: self,
                                            action: #selector(closeKeyboardMicroNutrient),
                                            forEvent: .touchUpInside)
        }

        [carbsSlider,proteinSlider,fatSlider].forEach { slider in
            slider?.transform = CGAffineTransform(rotationAngle:  .pi / -2)
            slider?.minimumValue = 0
            slider?.maximumValue = 100
        }
    }

    @objc private func closeKeyBoard() {
        if let value = self.caloriesValueTextField.text,
           let clories = Int(value),
           clories > 0 && clories < 9999{
            self.modelMacros.set(calories: clories)
        }
        view.endEditing(true)
        setUIToMatchMacros()
    }

    @objc private func closeKeyboardMicroNutrient(_ sender: UIButton) {

        switch sender.tag {
        case 0: self.modelMacros.set(carbs: Int(carbsPercentTextField.text ?? "") ?? 0)
        case 1: self.modelMacros.set(protein: Int(proteinPercentTextField.text ?? "") ?? 0)
        case 2: self.modelMacros.set(fat: Int(fatPercentTextField.text ?? "") ?? 0)
        default: break
        }
        view.endEditing(true)
        setUIToMatchMacros()
    }

    private func setUIToMatchMacros() {

        caloriesValueTextField.text = "\(modelMacros.caloriesTarget)"
        carbsValueLabel.text = "\(modelMacros.carbsGrams) \(Localized.gramUnit)"
        carbsPercentTextField.text = "\(modelMacros.carbsPercent)"
        carbsSlider.value = CFloat(modelMacros.carbsPercent)
        proteinValueLabel.text = "\(modelMacros.proteinGrams) \(Localized.gramUnit)"
        proteinPercentTextField.text = "\(modelMacros.proteinPercent)"
        proteinSlider.value = CFloat(modelMacros.proteinPercent)
        fatValueLabel.text = "\(modelMacros.fatGrams) \(Localized.gramUnit)"
        fatPercentTextField.text = "\(modelMacros.fatPercent)"
        fatSlider.value = CFloat(modelMacros.fatPercent)
    }

    @IBAction func cancel(_ sender: UIButton) {
        delegate?.pickerSelected(modelMacros: nil)
        self.dismiss(animated: true)
    }

    @IBAction func save(_ sender: UIButton) {
        delegate?.pickerSelected(modelMacros: modelMacros)
        self.dismiss(animated: true)
    }

    @IBAction func sliderValueChanged(_ sender: UISlider){
        switch sender.tag{
        case 0: self.modelMacros.set(carbs: Int(sender.value))
        case 1: self.modelMacros.set(protein: Int(sender.value))
        case 2: self.modelMacros.set(fat: Int(sender.value))
        default: break
        }
        self.setUIToMatchMacros()
    }
}

// MARK: - UITextField Delegate
extension PickerMacrosViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        guard let currentText = textField.text else {
            return true
        }
        let newText = (currentText as NSString).replacingCharacters(in: range,
                                                                    with: string).replacingOccurrences(of: "%",
                                                                                                       with: "")
        if let number = Int(newText) {
            if number > 100{
                textField.text = "100"
                return false
            }
        } else {
            textField.text = "0"
            return false
        }
        return true
    }
}
