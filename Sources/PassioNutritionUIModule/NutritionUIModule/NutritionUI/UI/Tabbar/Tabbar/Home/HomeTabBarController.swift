//
//  NutritionUITabbarViewController.swift
//  Nutritaion-ai
//
//  Created by Mind on 12/02/24.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

enum HemburgarMenuOptions: String {

    case profile = "My Profile"
    case settings = "Settings"
    case logout = "Log out"

    private var image: UIImage? {
        let name: String = {
            switch self {
            case .profile: return "userProfile"
            case .settings: return "settings"
            case .logout  : return "logOut"
            }
        }()
        return UIImage.imageFromBundle(named: name)
    }

    var pickerElememt: PickerElement {
        PickerElement(title: rawValue, image: image)
    }
}

final class HomeTabBarController: UITabBarController, UITabBarControllerDelegate {

    private enum Tabs: String {
        case home = "Home"
        case diary = "Diary"
        case mealPlan = "Meal Plan"
        case progress = "Progress"

        var naviagationTitle: String {
            switch self {
            case .home: return "Welcome \(UserManager.shared.user?.firstName ?? "")!"
            case .diary: return "My Diary"
            case .mealPlan: return "Meal Plan"
            case .progress: return "Progress"
            }
        }

        var tabImage: UIImage? {
            let name: String = {
                switch self {
                case .home: return "Home"
                case .diary: return "Book open"
                case .mealPlan: return "diet"
                case .progress  : return "Chart pie"
                }
            }()
            return UIImage.imageFromBundle(named: name)
        }
    }

    private var bottomTabs: [Tabs] = [.home, .diary, .mealPlan, .progress]

    override func viewDidLoad() {
        super.viewDidLoad()

        addTabBarControllers()
        configureUI()
        UserManager.shared.configure()
        DispatchQueue.global(qos: .background).async {
            FileManager.default.clearTempDirectory()
        }
        /** 
         Remove Nutrition Advisor history.
         We are storing history only for App session. Once App is re-opened,
         we need to clear history.
         */
        PassioUserDefaults.clearAdvisorHistory()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = bottomTabs[selectedIndex].naviagationTitle
        configureNavBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTabBarUI()
    }
}

// MARK: - Configure UI
extension HomeTabBarController {

    private func configureUI() {
        delegate = self
        guard let tabBar = self.tabBar as? HomeTabBar else { return }
        tabBar.didTapButton = { [unowned self] (button) in
            self.handlePlusButtonTap(button)
        }
        setTabBarItemsTitleAndPosition()
    }

    private func setTabBarItemsTitleAndPosition() {
        guard let tabBarItems = tabBar.items else { return }

        for i in 0..<bottomTabs.count {
            tabBarItems[i].title = bottomTabs[i].rawValue
            tabBarItems[i].image = bottomTabs[i].tabImage
        }

        tabBarItems[0].titlePositionAdjustment.horizontal = -6
        tabBarItems[1].titlePositionAdjustment.horizontal = -25
        tabBarItems[2].titlePositionAdjustment.horizontal = 25
        tabBarItems[3].titlePositionAdjustment.horizontal = 6
    }

    private func setupTabBarUI() {
        let height = view.safeAreaInsets.bottom + 64
        var tabFrame = tabBar.frame
        tabFrame.size.height = height
        tabFrame.origin.y = view.frame.size.height - height
        tabBar.tintColor = .primaryColor
        tabBar.unselectedItemTintColor = .secondaryTabColor
        tabBar.frame = tabFrame
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }

    private func addTabBarControllers() {

        for i in 0..<bottomTabs.count {

            switch bottomTabs[i] {

            case .home:
                let dashboardVC = UIStoryboard(name: "Home", bundle: PassioInternalConnector.shared.bundleForModule)
                    .instantiateViewController(identifier: "DashboardViewController") as! DashboardViewController
                let dashboardNavVC = UINavigationController(rootViewController: dashboardVC)
                dashboardNavVC.isNavigationBarHidden = true
                self.viewControllers?[i] = dashboardNavVC

            case .diary:
                let diaryVC = UIStoryboard(name: "Diary", bundle: PassioInternalConnector.shared.bundleForModule)
                    .instantiateViewController(identifier: "DiaryViewController") as! DiaryViewController
                let macroNavVC = UINavigationController(rootViewController: diaryVC)
                macroNavVC.isNavigationBarHidden = true
                self.viewControllers?[i] = macroNavVC

            case .progress:
                let progressVC = UIStoryboard(name: "Progress", bundle: PassioInternalConnector.shared.bundleForModule)
                    .instantiateViewController(identifier: "ProgressViewController") as! ProgressViewController
                let progressNavVC = UINavigationController(rootViewController: progressVC)
                progressNavVC.isNavigationBarHidden = true
                self.viewControllers?[i] = progressNavVC

            case .mealPlan:
                let mealPlanVC = UIStoryboard(name: "MealPlan", bundle: PassioInternalConnector.shared.bundleForModule)
                    .instantiateViewController(identifier: "MealPlanViewController") as! MealPlanViewController
                let mealPlanNavVC = UINavigationController(rootViewController: mealPlanVC)
                mealPlanNavVC.isNavigationBarHidden = true
                self.viewControllers?[i] = mealPlanNavVC
            }
        }
    }

    private func handlePlusButtonTap(_ sender: UIButton) {

        guard let parentView = self.navigationController?.view else { return }
        let frame = parentView.convert(sender.frame, from:sender.superview)
        let countedY = parentView.frame.size.height - (56.0 + frame.origin.y)

        let plusMenuVC = PlusMenuViewController()
        plusMenuVC.delegate = self
        plusMenuVC.bottomCountedValue = countedY
        presentVC(vc: plusMenuVC)
    }

    private func configureNavBar() {

        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.updateStatusBarColor(color: .statusBarColor)

        setupBackButton()

        let button = UIButton()
        button.setImage(UIImage.imageFromBundle(named: "menu"), for: .normal)
        button.addTarget(self, action: #selector(handleFilterButton(sender: )), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }

    // selector that's going to tigger on single tap on nav bar button
    @objc private func handleFilterButton(sender: UIButton) {

        let customPickerViewController = CustomPickerViewController()
        customPickerViewController.loadViewIfNeeded()

        let options: [HemburgarMenuOptions] = [.profile, .settings]
        customPickerViewController.pickerItems = options.map({$0.pickerElememt})

        if let frame = sender.superview?.convert(sender.frame, to: nil) {
            customPickerViewController.pickerFrame = CGRect(x: frame.origin.x - 130,
                                                            y: frame.origin.y + sender.frame.height + 10,
                                                            width: 130 + sender.frame.width,
                                                            height: 37 * CGFloat(options.count))
        }

        customPickerViewController.delegate = self
        customPickerViewController.modalTransitionStyle = .crossDissolve
        customPickerViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(customPickerViewController, animated: true, completion: nil)
    }
}

// MARK: - TabBar delegate
extension HomeTabBarController {

    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        title = bottomTabs[selectedIndex].naviagationTitle
    }
}

// MARK: - Plusbutton Navigation
extension HomeTabBarController: PlusMenuDelegate {

    func onFoodScannerSelected() {
        let vc = NutritionUICoordinator.getFoodRecognitionV3ViewController()
        vc.navigateToMyFoodsDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func onSearchSelected() {
        let vc = TextSearchViewController()
        vc.shouldPopVC = false
        vc.advancedSearchDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func onFavouritesSelected() {
        let vc = MyFavoritesViewController()
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }

    func onMyFoodsSelected() {
        let vc = MyFoodsSelectionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func onVoiceLoggingSelected() {
        let vc = VoiceLoggingViewController()
        vc.goToSearch = { [weak self] in
            self?.onSearchSelected()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func onTakePhotosSelected() {
        let vc = TakePhotosViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func onSelectPhotosSelected() {
        let vc = SelectPhotosViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func onNutritionAdvisorSelected() {
        let vc = NutritionAdvisorVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Plusbutton Navigation
extension HomeTabBarController: NavigateToMyFoodsDelegate {

    func onNavigateToMyFoods() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.navigationController?.pushViewController(MyFoodsSelectionViewController(), animated: true)
        })
    }
}

// MARK: - AdvancedTextSearchView Delegate
extension HomeTabBarController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {
        guard let foodRecord = record else { return }
        let editVC = FoodDetailsViewController()
        editVC.foodDetailsControllerDelegate = self
        editVC.isFromSearch = true
        editVC.foodRecord = foodRecord
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.navigationController?.pushViewController(editVC, animated: true)
        })
    }

    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool) {
        guard let foodItem = item else { return }
        let foodRecord = FoodRecordV3(foodItem: foodItem)
        let editVC = FoodDetailsViewController()
        editVC.foodDetailsControllerDelegate = self
        editVC.isFromSearch = true
        editVC.foodRecord = foodRecord
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.navigationController?.pushViewController(editVC, animated: true)
        })
    }
}
// MARK: - FoodDetails Delegate
extension HomeTabBarController: FoodDetailsControllerDelegate {

    func navigateToMyFoods(index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            let vc = MyFoodsSelectionViewController()
            vc.loadViewIfNeeded()
            vc.selectedIndex = index
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - CustomPickerSelection Delegate
extension HomeTabBarController: CustomPickerSelectionDelegate {

    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int) {

        let item = HemburgarMenuOptions(rawValue: value)

        switch item {
        case .profile:
            let profileVC = NutritionUICoordinator.getEditProfileViewController()
            navigationController?.pushViewController(profileVC, animated: true)
        case .settings:
            let settingsVC = NutritionUICoordinator.getEditSettingsViewController()
            navigationController?.pushViewController(settingsVC, animated: true)
        case .logout:
            break
        default: break
        }
    }
}
