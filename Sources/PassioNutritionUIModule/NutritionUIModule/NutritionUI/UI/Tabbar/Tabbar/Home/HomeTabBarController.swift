//
//  NutritionUITabbarViewController.swift
//  Nutritaion-ai
//
//  Created by Mind on 12/02/24.
//

import UIKit
import PassioNutritionAISDK

enum HemburgarMenuOptions: String {

    case profile = "My Profile"
    case tutorials = "Tutorials"
    case settings = "Settings"
    case logout = "Log out"

    private var image: UIImage? {
        let name: String = {
            switch self {
            case .profile: return "user_profile"
            case .tutorials: return "Tutorials"
            case .settings: return "settings"
            case .logout  : return "logout"
            }
        }()
        return UIImage.imageFromBundle(named: name)
    }

    var pickerElememt: PickerElement {
        PickerElement.init(title: self.rawValue, image: image)
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
                case .mealPlan: return "meal plan"
                case .progress  : return "Chart pie"
                }
            }()
            return UIImage.imageFromBundle(named: name)
        }
    }

    private var tabs: [Tabs] = [.home,.diary,.mealPlan,.progress]

    override func viewDidLoad() {
        super.viewDidLoad()

        UserManager.shared.configure()

        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.updateStatusBarColor(color: .white)

        for i in 0..<tabs.count {

            switch tabs[i] {

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

        configureUI()
        configureNavBar()
        MealPlanManager.shared.getMealPlans()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = tabs[selectedIndex].naviagationTitle
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

        for i in 0..<tabs.count {
            tabBarItems[i].title = tabs[i].rawValue
            tabBarItems[i].image = tabs[i].tabImage
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
        tabBar.frame = tabFrame
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }

    private func handlePlusButtonTap(_ sender: UIButton) {

        guard let parentView = self.navigationController?.view else { return }
        let frame = parentView.convert(sender.frame, from:sender.superview)
        let countedY = parentView.frame.size.height - (64.0 + frame.origin.y)

        let plusMenuVC = PlusMenuViewController()
        plusMenuVC.delegate = self
        plusMenuVC.bottomCountedValue = countedY
        plusMenuVC.modalTransitionStyle = .crossDissolve
        plusMenuVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(plusMenuVC, animated: true)
    }

    private func configureNavBar() {
        
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

        let options: [HemburgarMenuOptions] = [.profile, .settings, .logout]
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

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        title = tabs[selectedIndex].naviagationTitle
    }
}

// MARK: - Plusbutton Navigation
extension HomeTabBarController: PlusMenuDelegate {

    func onScanSelected() {
        let vc = NutritionUICoordinator.getScanningViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func onSearchSelected() {
        let vc = TextSearchViewController()
        vc.dismmissToMyLog = true
        vc.isAdvancedSearch = true
        vc.modalPresentationStyle = .fullScreen
        vc.advancedSearchDelegate = self
        self.present(vc, animated: true)
    }

    func onFavouritesSelected() {
        let vc = MyFavoritesViewController()
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func onMyFoodsSelected() {
        let vc = CreateFoodViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func onRecipesSelected() { }
}

extension HomeTabBarController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?) {
        guard let foodRecord = record else { return }
        let editVC = EditRecordViewController()
        editVC.foodRecord = foodRecord
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.navigationController?.pushViewController(editVC, animated: true)
        })
    }

    func userSelectedFoodItem(item: PassioFoodItem?) {
        guard let foodItem = item else { return }

        let foodRecord = FoodRecordV3(foodItem: foodItem)
        let editVC = EditRecordViewController()
        editVC.foodRecord = foodRecord
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.navigationController?.pushViewController(editVC, animated: true)
        })
    }
}

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
