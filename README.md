
# Passio-Nutrition-AI-iOS-UI-Module-Distribution

## 1. Add PassioNutritionUIModule as a Swift Package for Xcode 15 or newer
***Note:*** Please remove `PassioNutritionAISDK` from the project if you have already added it as a Swift Package. You don't need to add `PassioNutritionAISDK` because it is already included in PassioNutritionUIModule's dependencies. The UI Module and SDK are included in the `PassioNutritionUIModule` SPM as a Swift Package.
1.  Open your Xcode project.
2.  Go to File > Swift Packages > Add Package Dependency.
3.  In the "Add Package Dependency" dialog box, paste the URL:  [https://github.com/Passiolife/Passio-Nutrition-AI-iOS-UI-Module-Distribution](https://github.com/Passiolife/Passio-Nutrition-AI-iOS-UI-Module-Distribution)
4. In Dependency Rule select `upToNextMajorVersion` and set it to `1.0.0`.
5.  After you've made your selection, click "Add Package".
6.  You'll then be prompted to select the targets in your project that should include the package. Check the boxes for the targets you want to include and click "Add Package".
7.  The PassioNutritionUIModule and PassioNutritionAISDK, together with any additional dependencies required by PassioNutritionUIModule, will be downloaded and added to your project by Xcode. Now that you have the PassioNutritionUIModule imported, you may use it.
8. Set entry point for PassioNutritionUIModule to your current Xcode Project.
***Note:*** Please click this link https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution to learn how to configure `PassioNutritionAISDK` if you haven't already.

9. `import PassioNutritionUIModule` into the ViewController that you wish to designate as the PassioNutritionUIModule entry point.
10. Call the 'startPassioAppModule' method of the 'NutritionUIModule' class with a shared instance on UIButton's @IBAction or on any other function as per your requirement.
	```swift
	// Set navigationBar as per your app
	navigationController?.navigationBar.isHidden = false
	// Instantiate HomeTabBar Controller (Passio's Nutrition UI module)
    let vc = NutriationUICoordinator.getHomeTabbarViewController()
    // Use this method to navigate to Passio's Nutrition UI module
    NutritionUIModule.shared.startPassioAppModule(connector: passioExternalConnector,
                                                  presentingViewController: self,
                                                  withViewController: vc
                                                  passioConfiguration: passioConfig)

## 2. Add PassioNutritionUIModule source code directly to your Xcode Project (Only use this way when you want to fully custmoize UI module)

1. Download source code from the Repo.
2. Open your app’s Xcode project or workspace.
3. Choose File > Add Package Dependencies.
4. Click the Add Local button at the bottom of the package selection window.
5. Select the folder that contains the package (which we downloaded in step 1) and click the Add Package button.
6. Choose targets for the Package Products Xcode detects.
7. Now you can make changes to the local package and verify them by building and running the project.

***Note:*** 
Make sure to add below permissions in your Info.plist if you haven't already.
1. `<key>NSCameraUsageDescription</key>
	<string>Record video to analyze food</string>`
2. `<key>NSPhotoLibraryUsageDescription</key>
	<string>If the user would like to upload image of food that was not detected</string>`
3. `<key>NSSpeechRecognitionUsageDescription</key>
	<string>This app requires access to speech recognition to process your voice commands.</string>`
4. `<key>NSMicrophoneUsageDescription</key>
	<string>This app uses the microphone so that you can dictate the foods that you ate recently.</string>`

<br></br>
**© 2024 Passio, Inc. All rights reserved.**
