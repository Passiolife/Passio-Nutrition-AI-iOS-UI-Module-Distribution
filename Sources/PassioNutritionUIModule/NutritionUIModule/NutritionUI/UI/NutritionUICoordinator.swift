//
//  NutriationUICoordinator.swift
//  Nutritaion-ai
//
//  Created by Mind on 12/02/24.
//

import UIKit

public class NutritionUICoordinator {

    public class func getHomeTabbarViewController() -> UIViewController {
        loadViewController(storyboardName: "Home",
                           controllerName: "HomeTabBarController") as! HomeTabBarController
    }

    class func getScanningViewController() -> FoodRecognitionV3ViewController {
        loadViewController(storyboardName: "FoodRecognisation",
                           controllerName: "FoodRecognitionV3ViewController") as! FoodRecognitionV3ViewController
    }

    class func navigateToDairyAfterAction(navigationController: UINavigationController?,
                                          selectedDate: Date? = nil) {

        guard let vc = (navigationController?.viewControllers ?? []).first(where: {
            $0 is HomeTabBarController
        }) as? HomeTabBarController else {
            return
        }
        navigationController?.popToViewController(vc, animated: true)
        vc.selectedIndex = 1
        if let date = selectedDate,
           let diaryNavVC = vc.viewControllers?[1] as? UINavigationController,
           let diaryVC = diaryNavVC.viewControllers.first as? DiaryViewController {
            diaryVC.selectedDate = date
        }
    }

    class func getEditProfileViewController() -> EditProfileViewController {
        loadViewController(storyboardName: "EditProfile",
                           controllerName: "EditProfileViewController") as! EditProfileViewController
    }

    class func getEditSettingsViewController() -> EditSettingsViewController {
        loadViewController(storyboardName: "EditProfile",
                           controllerName: "EditSettingsViewController") as! EditSettingsViewController
    }

    private class func loadViewController(storyboardName: String,
                                          controllerName: String) -> UIViewController {

        let storyboard = UIStoryboard(name: storyboardName,
                                      bundle: PassioInternalConnector.shared.bundleForModule)
        let vc = storyboard.instantiateViewController(withIdentifier: controllerName)
        return vc
    }
}
