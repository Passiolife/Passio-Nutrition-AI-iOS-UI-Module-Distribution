//
//  EditProfileViewController.swift
//  PassioPassport
//
//  Created by zvika on 2/28/19.
//  Copyright © 2022 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

enum WeightGoal: String, CaseIterable
{
    case lose05
    case lose1
    case lose15
    case lose2
    case gain05
    case gain1
    case gain15
    case gain2
    case maintain
    
    var valueInLbs: String {
        switch self
        {
        case .lose05:
            return "Lose 0.5 \(Localized.lbsUnit) / Week"
        case .lose1:
            return "Lose 1 \(Localized.lbsUnit) / Week"
        case .lose15:
            return "Lose 1.5 \(Localized.lbsUnit) / Week"
        case .lose2:
            return "Lose 2 \(Localized.lbsUnit) / Week"
        case .gain05:
            return "Gain 0.5 \(Localized.lbsUnit) / Week"
        case .gain1:
            return "Gain 1 \(Localized.lbsUnit) / Week"
        case .gain15:
            return "Gain 1.5 \(Localized.lbsUnit) / Week"
        case .gain2:
            return "Gain 2 \(Localized.lbsUnit) / Week"
        case .maintain:
            return "Maintain Weight"
        }
    }
    
    var valueInKg: String {
        switch self
        {
        case .lose05:
            return "Lose 0.25 \(Localized.kgUnit) / Week"
        case .lose1:
            return "Lose 0.5 \(Localized.kgUnit) / Week"
        case .lose15:
            return "Lose 0.75 \(Localized.kgUnit) / Week"
        case .lose2:
            return "Lose 1 \(Localized.kgUnit) / Week"
        case .gain05:
            return "Gain 0.25 \(Localized.kgUnit) / Week"
        case .gain1:
            return "Gain 0.5 \(Localized.kgUnit) / Week"
        case .gain15:
            return "Gain 0.75 \(Localized.kgUnit) / Week"
        case .gain2:
            return "Gain 1 \(Localized.kgUnit) / Week"
        case .maintain:
            return "Maintain Weight"
        }
    }
}

final class EditProfileViewController: UIViewController {

    @IBOutlet private weak var profileTableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!

    private let hemburgarMenuOptions : [HemburgarMenuOptions] = [.settings]
    private let connector = PassioInternalConnector.shared
    private let chevFrame = CGRect(x: 0, y: 0, width: 15, height: 8)
    private var userProfile: UserProfileModel!
    private let values: [Float] = [0.5, 1.0, 1.5, 2.0, 0.5, 1.0, 1.5, 2.0]

    private var recomCalorie = 2100 {
        didSet {
            userProfile.recommendedCalories = recomCalorie > 0 ? recomCalorie : 2100
        }
    }
    private var goalTimeLine: String = Localized.maintainWeight {
        didSet {
            recomCalorie = calculateRecommendedCalorie()
        }
    }

    private enum CellsProfile: String, CaseIterable {
        case UserPreferencesCell, CalculatedBMICell, DailyNutritionGoalsCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureNavBar()
        if MealPlanManager.shared.mealPlans.count == 0 {
            MealPlanManager.shared.getMealPlans()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userProfile = UserManager.shared.user ?? UserProfileModel()
        profileTableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    private func configureNavBar() {
        self.setupBackButton()

        let menuButton = UIButton()
        menuButton.setImage(UIImage.imageFromBundle(named: "menu"), for: .normal)
        menuButton.addTarget(self, action: #selector(handleMenuButton(sender: )), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
    }

    @objc private func handleMenuButton(sender: UIButton) {

        let customPickerViewController = CustomPickerViewController()
        customPickerViewController.viewTag = -1
        customPickerViewController.loadViewIfNeeded()
        customPickerViewController.pickerItems = hemburgarMenuOptions.map { $0.pickerElememt }

        if let frame = sender.superview?.convert(sender.frame, to: nil) {
            customPickerViewController.pickerFrame = CGRect(x: frame.origin.x - 130,
                                                            y: frame.origin.y + sender.frame.height + 10,
                                                            width: 130 + sender.frame.width,
                                                            height: 42.5 * CGFloat(hemburgarMenuOptions.count))
        }

        customPickerViewController.delegate = self
        customPickerViewController.modalTransitionStyle = .crossDissolve
        customPickerViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(customPickerViewController, animated: true, completion: nil)
    }

    func hemburgerOptionSelected(index: Int) {
        switch self.hemburgarMenuOptions[index] {
        case .settings:
            let settingsVC = NutritionUICoordinator.getEditSettingsViewController()
            self.navigationController?.pushViewController(settingsVC, animated: true)
            break
        default:
            break
        }
    }
}

// MARK: - Configure UI
extension EditProfileViewController {

    private func configureUI() {

        title = Localized.profile

        profileTableView.dataSource = self
        profileTableView.delegate = self
        CellsProfile.allCases.forEach {
            profileTableView.register(nibName: $0.rawValue)
        }
        saveButton.backgroundColor = .primaryColor
    }

    @IBAction func onSaveChanges(_ sender: UIButton) {
        showMessage(msg: "Profile Saved", bgColor: .gray500)
        UserManager.shared.user = userProfile
        connector.updateUserProfile(userProfile: userProfile)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Helper
extension EditProfileViewController {

    private func calculateBMR() -> (Double?, ActivityLevel?) {
        var BMR = 0.0
        var height = 0.0
        guard let activityLevel = userProfile.activityLevel,
              let age = userProfile.age,
              let pHeight = userProfile.height,
              let pWeight = userProfile.weight,
              let gender = userProfile.gender else { return (nil, nil) }

        height = pHeight * 100
        let calWeight = 10 * pWeight

        if gender == .male {
            BMR = calWeight + (6.25 * height) - Double((5 * age)) + 5 // Kg, cm
        } else {
            BMR = calWeight + (6.25 * height) - Double((5 * age)) - 161 // Kg, cm
        }
        return (BMR, activityLevel)
    }

    private func calculateCaloriesBasedOnActivityLevel() -> Int {
        let (bmr, activityLevel) = calculateBMR()
        guard let bmr = bmr else {
            return 0
        }
        switch activityLevel {
        case .notActive:
            return Int(bmr * 1.2)
        case .lightlyActive:
            return Int(bmr * 1.375)
        case .active:
            return Int(bmr * 1.725)
        case .moderatelyActive:
            return Int(bmr * 1.55)
        case .none:
            return 2100
        }
    }

//    private func calculateRecommendedCalorie() -> Int {
//        var calories = calculateCaloriesBasedOnActivityLevel()
//        let weightGoalTimeLine = userProfile.goalWeightTimeLine ?? Localized.maintainWeight
//        let goalValues = calorieDeficitArray
//
//        switch weightGoalTimeLine {
//        case getLocalisedValue(goalValue: 0.5, key: goalValues[0]):
//            calories -= 250
//        case getLocalisedValue(goalValue: 1.0, key: goalValues[1]):
//            calories -= 500
//        case getLocalisedValue(goalValue: 1.5, key: goalValues[2]):
//            calories -= 750
//        case getLocalisedValue(goalValue: 2.0, key: goalValues[3]):
//            calories -= 1000
//        case getLocalisedValue(goalValue: 0.5, key: goalValues[4]):
//            calories += 250
//        case getLocalisedValue(goalValue: 1.0, key: goalValues[5]):
//            calories += 500
//        case getLocalisedValue(goalValue: 1.5, key: goalValues[6]):
//            calories += 750
//        case getLocalisedValue(goalValue: 2.0, key: goalValues[7]):
//            calories += 1000
//        case Localized.maintainWeight:
//            calories += 0
//        default:
//            calories += 0
//        }
//        return calories
//    }
    
    private func calculateRecommendedCalorie() -> Int {
        var calories = calculateCaloriesBasedOnActivityLevel()
        let weightGoal: WeightGoal = WeightGoal(rawValue: userProfile.goalWeightTimeLine ?? "") ?? .maintain

        switch weightGoal {
        case .lose05:
            calories -= 250
        case .lose1:
            calories -= 500
        case .lose15:
            calories -= 750
        case .lose2:
            calories -= 1000
        case .gain05:
            calories += 250
        case .gain1:
            calories += 500
        case .gain15:
            calories += 750
        case .gain2:
            calories += 1000
        case .maintain:
            calories += 0
        default:
            calories += 0
        }
        return calories
    }

    @objc private func showHeightPickerView() {
        view.endEditing(true)
        let editSB = UIStoryboard(name: "EditProfile", bundle: .module)
        let pickerView = editSB.instantiateViewController(
            withIdentifier: "CommonPickerViewController"
        ) as! CommonPickerViewController
        let unitDescption = userProfile.heightUnits == .imperial ? Localized.feetUnit : Localized.meterUnit
        pickerView.title = Localized.height + " " + "(\(unitDescption))"
        pickerView.data = userProfile.heightArrayForPicker
        pickerView.selectedIndexes =  userProfile.heightInitialValueForPicker
        pickerView.delegate = self
        pickerView.modalTransitionStyle = .crossDissolve
        pickerView.modalPresentationStyle = .overCurrentContext
        self.navigationController?.presentVC(vc: pickerView, isAnimated: true)
    }

    private func showPicker(sender: UIButton, items: [String], viewTag: Int) {

        view.endEditing(true)

        let customPickerViewController = CustomPickerViewController()
        customPickerViewController.loadViewIfNeeded()
        customPickerViewController.disableCapatlized = true
        customPickerViewController.pickerItems = items.map { PickerElement(title: $0) }
        customPickerViewController.viewTag = viewTag
        if let frame = sender.superview?.convert(sender.frame, to: nil) {
            let pickerHeight = 36.5 * Double(items.count)
            let frameOrigin = frame.origin
            let y = frameOrigin.y > (ScreenSize.height / 2) ? ((frameOrigin.y - 10) - (pickerHeight)) : frameOrigin.y + 50
            customPickerViewController.pickerFrame = CGRect(x: frameOrigin.x - 5,
                                                            y: y <= 91 ? 91 : y,
                                                            width: frame.width + 20,
                                                            height: pickerHeight)
        }
        customPickerViewController.delegate = self
        presentVC(vc: customPickerViewController)
    }

    @objc private func showActivityLevelPickerView(_ sender: UIButton) {
        let items = ActivityLevel.allCases.map { $0.rawValue }
        showPicker(sender: sender, items: items, viewTag: 5)
    }

//    @objc private func showCalorieDeficitPickerViewOld(_ sender: UIButton) {
//        let items = calorieDeficitArray
//        let goalValues = [getLocalisedValue(goalValue: 0.5, key: items[0]),
//                          getLocalisedValue(goalValue: 1.0, key: items[1]),
//                          getLocalisedValue(goalValue: 1.5, key: items[2]),
//                          getLocalisedValue(goalValue: 2.0, key: items[3]),
//                          getLocalisedValue(goalValue: 0.5, key: items[4]),
//                          getLocalisedValue(goalValue: 1.0, key: items[5]),
//                          getLocalisedValue(goalValue: 1.5, key: items[6]),
//                          getLocalisedValue(goalValue: 2.0, key: items[7]),
//                          items[8]]
//        showPicker(sender: sender, items: goalValues, viewTag: 11)
//    }
    
    @objc private func showCalorieDeficitPickerView(_ sender: UIButton) {
        
        let items = userProfile.units == .imperial ? WeightGoal.allCases.map{$0.valueInLbs} : WeightGoal.allCases.map{$0.valueInKg}
        showPicker(sender: sender, items: items, viewTag: 11)
    }
    
    func getGoalValue(for value: Float) -> String {
        let value = userProfile.units == .imperial ? Float(value*2) : Float(value)
        return value.clean
    }

    @objc private func showGenderPickerView(_ sender: UIButton){
        let gender = [GenderSelection.male,GenderSelection.female].map({$0.rawValue.capitalizingFirst()})
        showPicker(sender: sender, items: gender, viewTag: 4)
    }

    private func getLocalisedValue(goalValue: Double, key: String) -> String {
        let unitString = userProfile.units == .imperial ? Localized.lbsUnit : Localized.kgUnit
        let value = userProfile.units == .imperial ? Float(goalValue) : Float(goalValue * Conversion.kgToLbs.rawValue)
        let valueString = String(format: "%.1f", value)
        return String(format: NSLocalizedString(key, comment: ""), valueString, unitString)
    }

    @objc private func showDietPickerView(_ sender: UIButton) {
        let items = MealPlanManager.shared.mealPlans.map { $0.mealPlanTitle ?? "" }
        showPicker(sender: sender, items: items, viewTag: 12)
    }

    @objc private func showMacroNutrientPickerView() {
        view.endEditing(true)
        let editSB = UIStoryboard(name: "EditProfile", bundle: .module)
        let pickerView = editSB.instantiateViewController(
            withIdentifier: "PickerMacrosViewController"
        ) as! PickerMacrosViewController
        let macros = Macros(caloriesTarget: userProfile.caloriesTarget,
                            carbsPercent: userProfile.carbsPercent,
                            proteinPercent: userProfile.proteinPercent,
                            fatPercent: userProfile.fatPercent)
        pickerView.modelMacros = macros
        pickerView.delegate = self
        pickerView.modalTransitionStyle = .crossDissolve
        pickerView.modalPresentationStyle = .overCurrentContext
        self.navigationController?.presentVC(vc: pickerView, isAnimated: true)
    }

    @objc private func closeKeyBoard() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource
extension EditProfileViewController: UITableViewDataSource,UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return getUserPreferencesCell(indexpath: indexPath, profile: userProfile)
        case 1:
            return getDailyNutritionGoalsCell(indexpath: indexPath, profile: userProfile)
        case 2:
            return getCalculateBMICell(indexpath: indexPath)
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            self.showMacroNutrientPickerView()
        }
    }

    // MARK: Cells
    private func getUserPreferencesCell(indexpath: IndexPath,
                                        profile: UserProfileModel?) -> UITableViewCell {
        let cell = profileTableView.dequeueCell(cellClass: UserPreferencesCell.self,
                                                forIndexPath: indexpath)
        cell.configureCell(userProfile: userProfile)
        cell.userPreferencesTextFields.forEach {
            switch $0.tag {
            case 0, 1, 3, 4, 10,14:
                $0.delegate = self
                $0.clearsOnBeginEditing = true
                $0.addOkButtonToToolbar(target: self,
                                        action: #selector(closeKeyBoard),
                                        forEvent: .touchUpInside)
            default:
                $0.addImageInTextField(isLeftImg: false,
                                       image: UIImage(systemName: "chevron.down")?
                    .withTintColor(.gray900, renderingMode: .alwaysOriginal) ?? UIImage(),
                                       imageFrame: chevFrame)
            }
        }
        cell.heightButton.addTarget(self,
                                    action: #selector(showHeightPickerView),
                                    for: .touchUpInside)
        cell.activityLevelButton.addTarget(self,
                                           action: #selector(showActivityLevelPickerView),
                                           for: .touchUpInside)
        cell.calorieDeficitButton.addTarget(self,
                                            action: #selector(showCalorieDeficitPickerView),
                                            for: .touchUpInside)
        cell.genderButton.addTarget(self,
                                    action: #selector(showGenderPickerView),
                                    for: .touchUpInside)
        cell.dietButton.addTarget(self,
                                  action: #selector(showDietPickerView),
                                  for: .touchUpInside)
        return cell
    }

    private func getCalculateBMICell(indexpath: IndexPath) -> UITableViewCell {
        let cell = profileTableView.dequeueCell(cellClass: CalculatedBMICell.self,
                                                forIndexPath: indexpath)
        cell.setBMIValue(bmiValue: userProfile.bmi ?? 1.0,
                         bmiDescription: userProfile.bmiDescription)
        return cell
    }

    private func getDailyNutritionGoalsCell(indexpath: IndexPath,
                                            profile: UserProfileModel?) -> UITableViewCell {
        let cell = profileTableView.dequeueCell(cellClass: DailyNutritionGoalsCell.self,
                                                forIndexPath: indexpath)
        cell.updateProfile(userProfile: userProfile)
        return cell
    }
}

// MARK: - PickerPopUpView Delegate
extension EditProfileViewController: CommonPickerViewControllerDelegate {
    func pickerSelected(result: [Int]?) {
        guard let _result = result else { return }
        userProfile.setHeightInMetersFor(compOne: _result[0], compTwo: _result[1])
        recomCalorie = calculateRecommendedCalorie()
        profileTableView.reloadData()
    }
}

// MARK: - CustomPickerSelection Delegate
extension EditProfileViewController: CustomPickerSelectionDelegate {

    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int) {
        switch viewTag {
        case -1:
            self.hemburgerOptionSelected(index: selectedIndex)
        case 5: // Activity Level
            userProfile.setActivityLevel(compOne: selectedIndex)
        case 4:
            userProfile.gender = GenderSelection.init(rawValue: value.lowercased()) ?? .male
        case 12: // Diet
            let mealPlan = MealPlanManager.shared.mealPlans[selectedIndex]
            userProfile.mealPlan = mealPlan
            if let carbs = mealPlan.carbsTarget,
               let protien = mealPlan.proteinTarget,
               let fat = mealPlan.fatTarget{
                userProfile.carbsPercent = carbs
                userProfile.proteinPercent = protien
                userProfile.fatPercent = fat
            }
        case 11:
            let weightGoal = WeightGoal.allCases[selectedIndex]
            userProfile.goalWeightTimeLine = weightGoal.rawValue
            goalTimeLine = userProfile.goalWeightTimeLine ?? Localized.maintainWeight
        default:
            break
        }
        recomCalorie = calculateRecommendedCalorie()
        profileTableView.reloadData()
    }
}

// MARK: - PickerMacroView Delegate
extension EditProfileViewController: PickerMacroViewDelegate {
    func pickerSelected(modelMacros: Macros?) {
        if let modelMacros = modelMacros {
            userProfile.caloriesTarget = modelMacros.caloriesTarget
            userProfile.carbsPercent = modelMacros.carbsPercent
            userProfile.proteinPercent = modelMacros.proteinPercent
            userProfile.fatPercent = modelMacros.fatPercent
        }
        self.profileTableView.reloadData()
    }
}

// MARK: - UITextField Delegate
extension EditProfileViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.profileTableView.contentInset = UIEdgeInsets(top: 0,
                                                              left: 0,
                                                              bottom: textField.tag >= 7 ? 480 : 0,
                                                              right: 0)
        }, completion: nil)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 4,10: // check if valid weight
            if let weight = textField.text, let _ = Double(weight) {
                textField.resignFirstResponder()
                return true
            } else {
                return false
            }
        case 14:
            if let goalWater = textField.text, let _ = Double(goalWater) {
                textField.resignFirstResponder()
                return true
            }else {
                return false
            }
        case 1: // check if valid age
            if let age = textField.text, let dAge = Double(age), dAge > 0 {
                textField.resignFirstResponder()
                return true
            } else {
                return false
            }
        default:
            textField.resignFirstResponder()
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch textField.tag {
        case 0: // Name
            if let name = textField.text,
               !name.isEmpty {
                userProfile.firstName = name
            }
        case 4: // Weight
            if let _weight = textField.text,
               let dWeight = Double(_weight),
               dWeight > 0 {
                userProfile.weight = userProfile.units == .imperial ? dWeight/Conversion.lbsToKg.rawValue : dWeight
            }
        case 10: // Goal Weight
            if let _weight = textField.text,
               let dWeight = Double(_weight),
               dWeight > 0 {
                userProfile.goalWeight = userProfile.units == .imperial ? dWeight/Conversion.lbsToKg.rawValue : dWeight
            }
        case 1: // Age
            if let age = textField.text,
               let dAge = Int(age),
               dAge > 0 {
                userProfile.age = dAge
            }
        case 14:
            if let _water = textField.text, let dWater = Double(_water), dWater > 0 {
                userProfile.goalWater = dWater
            }
        default:
            break
        }
        recomCalorie = calculateRecommendedCalorie()
        profileTableView.reloadData()
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
            self.profileTableView.contentInset = UIEdgeInsets(top: 0,
                                                              left: 0,
                                                              bottom: 55,
                                                              right: 0)
        }, completion: nil)
    }
}
