//
//  EditSettingsViewController.swift
//  BaseApp
//
//  Created by Mind on 15/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit

class EditSettingsViewController: UIViewController {

    @IBOutlet weak var heightUnitTextfield: UITextField!
    @IBOutlet weak var unitTextfield: UITextField!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var heightUnitButtom: UIButton!
    @IBOutlet weak var reminderBreakfastSwitch: UISwitch!
    @IBOutlet weak var reminderLunchSwitch: UISwitch!
    @IBOutlet weak var reminderDinnerSwitch: UISwitch!
    @IBOutlet weak var unitContainerView: UIView!
    @IBOutlet weak var reminderContainerView: UIView!

    var userProfile: UserProfileModel?
    let connector = PassioInternalConnector.shared
    var unitType = UnitSelection.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userProfile = UserManager.shared.user
        setupProfile()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
        if let profile = userProfile{
            UserManager.shared.user = self.userProfile
            connector.updateUserProfile(userProfile: profile)
        }
    }

    private func setupUI() {
        [unitTextfield,heightUnitTextfield].forEach { textField in
            textField?.configureTextField()
            textField?.addImageInTextField(isLeftImg: false,
                                           image: UIImage(systemName: ImageName.chevDown)?
                .withTintColor(.gray900, renderingMode: .alwaysOriginal) ?? UIImage(),
                                           imageFrame: CGRect(x: 0, y: 0, width: 15, height: 8))
        }
        unitButton.addTarget(self, action: #selector(showUnit), for: .touchUpInside)
        heightUnitButtom.addTarget(self, action: #selector(showUnit), for: .touchUpInside)

        [unitContainerView,reminderContainerView].forEach({
            $0?.dropShadow()
        })

        [reminderBreakfastSwitch,reminderDinnerSwitch,reminderLunchSwitch].forEach({
            $0?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        })

        title = "Settings"
        setupBackButton()
    }

    private func setupProfile() {

        unitTextfield.text = userProfile?.units.weightDisplay
        heightUnitTextfield.text = userProfile?.heightUnits.heightDisplay
        reminderBreakfastSwitch.isOn = userProfile?.reminderSettings?.breakfast ?? false
        reminderLunchSwitch.isOn = userProfile?.reminderSettings?.lunch ?? false
        reminderDinnerSwitch.isOn = userProfile?.reminderSettings?.dinner ?? false
    }

    @objc private func showUnit(_ sender: UIButton) {
        let items: [String] = switch sender.tag {
        case 0:
            unitType.map { $0.heightDisplay }
        case 1:
            unitType.map { $0.weightDisplay }
        default:
            []
        }
        showPicker(sender: sender, items: items, viewTag: sender.tag)
    }

    private func showPicker(sender: UIButton, items: [String], viewTag: Int) {
        view.endEditing(true)
        let customPickerViewController = CustomPickerViewController()
        if sender == unitButton {
            customPickerViewController.disableCapatlized = true
        }
        customPickerViewController.loadViewIfNeeded()
        customPickerViewController.pickerItems = items.map({PickerElement.init(title: $0)})
        customPickerViewController.viewTag = viewTag
        if let frame = sender.superview?.convert(sender.frame, to: nil) {
            let pickerHeight = 39.5 * Double(items.count)
            let frameOrigin = frame.origin
            let y = frameOrigin.y > (ScreenSize.height/2) ? ((frameOrigin.y-10) - (pickerHeight)) : frameOrigin.y+50
            customPickerViewController.pickerFrame = CGRect(x: frameOrigin.x-5,
                                                            y: y,
                                                            width: frame.width+10,
                                                            height: pickerHeight)
        }
        customPickerViewController.delegate = self
        presentVC(vc: customPickerViewController)
    }
}

// MARK: - CustomPickerSelection Delegate
extension EditSettingsViewController: CustomPickerSelectionDelegate {

    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int) {
        switch viewTag {
        case 0:
            userProfile?.heightUnits = unitType[selectedIndex]
        case 1:
            userProfile?.units = unitType[selectedIndex]
        default:
            break
        }
        setupProfile()
    }

    @IBAction func onSwitchValueChanged() {
        var reminderSettings = ReminderSettings()
        reminderSettings.breakfast = reminderBreakfastSwitch.isOn
        reminderSettings.lunch = reminderLunchSwitch.isOn
        reminderSettings.dinner = reminderDinnerSwitch.isOn
        userProfile?.reminderSettings = reminderSettings
    }
}
