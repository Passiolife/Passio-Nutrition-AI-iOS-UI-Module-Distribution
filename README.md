# Passio-Nutrition-AI-iOS-UI-Module-Distribution

### 1. Add PassioNutritionUIModule as a Swift Package for Xcode 15 or newer
***Note:*** Please remove `PassioNutritionAISDK` from the project if you have already added it as a Swift Package. You don't need to add `PassioNutritionAISDK` because it is already included in PassioNutritionUIModule's dependencies. The UI Module and SDK are included in the `PassioNutritionUIModule` SPM as a Swift Package.
1.  Open your Xcode project.
2.  Go to File > Swift Packages > Add Package Dependency.
3.  In the "Add Package Dependency" dialog box, paste the URL:  [https://github.com/Passiolife/Passio-Nutrition-AI-iOS-UI-Module-Distribution](https://github.com/Passiolife/Passio-Nutrition-AI-iOS-UI-Module-Distribution)
4. In Dependency Rule select `upToNextMajorVersion` and set it to `1.0.0`.
5.  After you've made your selection, click "Add Package".
6.  You'll then be prompted to select the targets in your project that should include the package. Check the boxes for the targets you want to include and click "Add Package".
7.  The PassioNutritionUIModule and PassioNutritionAISDK, together with any additional dependencies required by PassioNutritionUIModule, will be downloaded and added to your project by Xcode. Now that you have the PassioNutritionUIModule imported, you may use it.

### 2. Set entry point for PassioNutritionUIModule to your current Xcode Project.
***Note:*** Please click this link https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution to learn how to configure `PassioNutritionAISDK` if you haven't already.

1. `import PassioNutritionUIModule` into the ViewController that you wish to designate as the PassioNutritionUIModule entry point.
2. Call the 'startPassioAppModule' method of the 'PassioInternalConnector' class with a shared instance on UIButton's @IBAction or on any other function as per your requirement.
	```swift
	// Set navigationBar as per your app
	navigationController?.navigationBar.isHidden = false
	// Instantiate HomeTabBar Controller (Passio's Nutrition UI module)
    let vc = NutriationUICoordinator.getHomeTabbarViewController()
    // Use this method to navigate to Passio's Nutrition UI module
    PassioInternalConnector.shared.startPassioAppModule(passioExternalConnector: passioExternalConnector,
		                                                presentingViewController: self,
		                                                withViewController: vc
		                                                passioConfiguration: passioConfig)
   ```
After completing the steps above, you should be able to navigate to `PassioNutritionUIModule`.

***Note:*** Make sure to add `<key>>NSCameraUsageDescription</key><string>For real-time food recognition</string>`. in your Info.plist if you haven't already.

<br></br>
**© 2024 Passio, Inc. All rights reserved.**
