//
//  FoodRecognitionViewController.swift
//  BaseApp
//
//  Created by zvika on 1/21/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
import AVFoundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

final class FoodRecognitionV3ViewController: UIViewController {

    @IBOutlet weak var cameraButtonStackView: UIStackView!
    @IBOutlet weak var wholeFoodsButton: UIButton!
    @IBOutlet weak var barcodeButton: UIButton!
    @IBOutlet weak var nutritionFactsButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var foodDetectedView: UIView!
    @IBOutlet weak var nutritionDetectedView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var zoomSlider: UISlider!
    @IBOutlet weak var flashLightButton: UIButton!
    @IBOutlet weak var focusButton: UIButton!

    private let passioSDK = PassioNutritionAI.shared
    private let connector = PassioInternalConnector.shared
    private var volumeDetectionMode = VolumeDetectionMode.none
    private var videoLayer: AVCaptureVideoPreviewLayer?
    private var timer: Timer?
    private var isRecognitionsPaused = false
    private var workItem: DispatchWorkItem?
    private var isFlashlightOn: Bool = false
    private let white40Color = UIColor.white.withAlphaComponent(0.40)
    private var detectionConfig: FoodDetectionConfiguration!

    weak var navigateToMyFoodsDelegate: NavigateToMyFoodsDelegate?
    weak var navigateToRecipeDelegate: NavigateToRecipeDelegate?
    var resultViewFor: DetectedFoodResultType = .addLog
    
    private var scanMode: ScanMode = .wholeFoods {
        didSet {
            setupScanModeButtonsUI()
            passioSDK.stopFoodDetection()
            isRecognitionsPaused = true
            dataset = nil
            configureFoodDetection()
        }
    }

    private enum ScanMode {
        case wholeFoods, barcode, nutritionFacts
    }

    public var dataset: (any FoodRecognitionDataSet)? {
        didSet {
            Task { @MainActor in

                sendCameraViewToBack(isSendBack: false)

                if dataset != nil {
                    tempDataset = dataset
                }
                if let dataset = dataset as? NutritionFactsDataSet {
                    nutritionDetectedView.isHidden = false
                    foodDetectedView.isHidden = true
                    nutritionFactResultVC?.updateDataset(dataset)
                } else {
                    nutritionDetectedView.isHidden = true
                    foodDetectedView.isHidden = false
                    foodResultVC?.updateDataSet(newDataSet: dataset)
                }
            }
        }
    }
    private var tempDataset: (any FoodRecognitionDataSet)? = nil {
        didSet {
            if tempDataset == nil {
                workItem = DispatchWorkItem.init(block: { [weak self] () in
                    guard let self else { return }
                    if tempDataset == nil {
                        dataset = nil
                    }
                })
                if workItem != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem!)
                }
            } else {
                workItem?.cancel()
            }
        }
    }
    private var isFocusEnabled = false {
        didSet {
            focusButton.setImage(UIImage(resource: isFocusEnabled ? .focusIcon : .focusOffIcon),
                                 for: .normal)
        }
    }
    private var isHintPresented: Bool = false {
        didSet {
            if isHintPresented {
                pauseDetection()
            } else {
                dataset = nil
                configureFoodDetection()
            }
        }
    }
    lazy var foodResultVC: DetectedFoodResultView? = {
        let vc = children.first(where: {
            $0 is DetectedFoodResultView
        }) as? DetectedFoodResultView
        return vc
    }()
    lazy var nutritionFactResultVC: DetectedNutriFactResultViewController? = {
        let vc = children.first(where: {
            $0 is DetectedNutriFactResultViewController }
        ) as? DetectedNutriFactResultViewController
        return vc
    }()

    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if !PassioUserDefaults.bool(for: .scanningOnboardingCompleted) {
            PassioUserDefaults.store(for: .scanningOnboardingCompleted, value: true)
            presentHint()
        }

        dataset = nil
        setupNavigation()
        detectionConfig = FoodDetectionConfiguration(detectVisual: true,
                                                     volumeDetectionMode: volumeDetectionMode,
                                                     detectBarcodes: false,
                                                     detectPackagedFood: true)
        foodResultVC?.delegate = self
        foodResultVC?.resultViewFor = self.resultViewFor
        nutritionFactResultVC?.delegate = self
        activityIndicator.color = .primaryColor
        zoomSlider.minimumTrackTintColor = .primaryColor
        
        if resultViewFor == .addIngredient {
            self.nutritionFactsButton.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized { // already authorized
            setupVideoAndStartDetection()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] (granted) in
                if granted { // access to video granted
                    self?.setupVideoAndStartDetection()
                } else {
                    print("The user didn't grant access to use camera")
                }
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            if isRecognitionsPaused {
                if (foodResultVC?.containerViewHeightConstraint?.constant ?? -1) == 0
                    && presentedViewController == nil {
                    foodResultVC?.resultViewFor = self.resultViewFor
                    configureFoodDetection()
                }
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        timer?.invalidate()
        passioSDK.stopFoodDetection()
        isRecognitionsPaused = true
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
        passioSDK.removeVideoLayer()
    }
}

// MARK: - @IBAction
private extension FoodRecognitionV3ViewController {

    @IBAction func onScanMode(_ sender: UIButton) {
        scanMode = switch sender.tag {
        case 0: .wholeFoods
        case 1: .barcode
        case 2: .nutritionFacts
        default: .wholeFoods
        }
    }

    @IBAction func onZoomLevelChanged(_ sender: UISlider) {
        guard let _ = videoLayer else { return }
        if sender.value < 1 { return }
        passioSDK.setCamera(toVideoZoomFactor: CGFloat(sender.value))
    }

    @objc func presentHint() {
        stopDetection()
        isHintPresented = true
        ScanningHintViewController.presentHint(presentigVC: navigationController, resultViewFor: resultViewFor) { [weak self] in
            guard let self else { return }
            isHintPresented = false
        }
    }

    @IBAction func onFocusTapped(_ sender: UIButton) {
        isFocusEnabled.toggle()
    }

    func addTapGestureForFocus() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapToFocus))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func onTapToFocus(_ gesture: UITapGestureRecognizer) {
        guard let videoLayer = videoLayer, isFocusEnabled else { return }
        let tappedPoint = gesture.location(in: view)
        let convertedPoint = videoLayer.captureDevicePointConverted(fromLayerPoint: tappedPoint)
        passioSDK.setTapToFocus(pointOfInterest: convertedPoint)
    }

    @IBAction func onFlashlight(_ sender: UIButton) {
        passioSDK.enableFlashlight(enabled: !isFlashlightOn, level: 1)
        isFlashlightOn.toggle()
        flashLightButton.setImage(UIImage(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill"),
                                  for: .normal)
    }
}

// MARK: - Helper methods: Food Detection
private extension FoodRecognitionV3ViewController {

    func setupScanModeButtonsUI() {

        var zoomValue: Float

        switch scanMode {
        case .wholeFoods:
            wholeFoodsButton.animateBackgroundColor(color: .primaryColor)
            barcodeButton.animateBackgroundColor(color: white40Color)
            nutritionFactsButton.animateBackgroundColor(color: white40Color)
            zoomValue = 1

        case .barcode:
            wholeFoodsButton.animateBackgroundColor(color: white40Color)
            barcodeButton.animateBackgroundColor(color: .primaryColor)
            nutritionFactsButton.animateBackgroundColor(color: white40Color)
            zoomValue = 1.5

        case .nutritionFacts:
            wholeFoodsButton.animateBackgroundColor(color: white40Color)
            barcodeButton.animateBackgroundColor(color: white40Color)
            nutritionFactsButton.animateBackgroundColor(color: .primaryColor)
            zoomValue = 1
        }
        zoomSlider.setValue(zoomValue, animated: true)
        passioSDK.setCamera(toVideoZoomFactor: CGFloat(zoomValue))
    }

    func configureFoodDetection() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in

            guard let self else { return }

            switch scanMode {

            case .wholeFoods:
                detectionConfig.detectVisual = true
                detectionConfig.detectPackagedFood = true
                detectionConfig.detectBarcodes = false

            case .barcode:
                detectionConfig.detectVisual = false
                detectionConfig.detectPackagedFood = false
                detectionConfig.detectBarcodes = true

            case .nutritionFacts:
                detectionConfig.detectVisual = false
                detectionConfig.detectPackagedFood = true
                detectionConfig.detectBarcodes = false
            }

            if scanMode == .nutritionFacts {
                startNutritionFactsDetection()
            } else {
                startFoodDetection(with: detectionConfig)
            }
        }
    }

    func sendCameraViewToBack(isSendBack: Bool) {
        if isSendBack {
            view.insertSubview(zoomSlider, belowSubview: foodDetectedView)
            view.insertSubview(cameraButtonStackView, belowSubview: foodDetectedView)
            view.insertSubview(zoomSlider, belowSubview: nutritionDetectedView)
            view.insertSubview(cameraButtonStackView, belowSubview: nutritionDetectedView)
        } else {
            view.bringSubviewToFront(cameraButtonStackView)
            view.bringSubviewToFront(zoomSlider)
        }
    }

    func setupNavigation() {

        title = "Food Scanner"
        setupBackButton()
        navigationController?.isNavigationBarHidden = false
        let rightButton = UIBarButtonItem(image: UIImage.imageFromBundle(named: "hint_icon"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(presentHint))
        rightButton.tintColor = .gray400
        navigationItem.rightBarButtonItem = rightButton
    }

    func setupVideoAndStartDetection() {
        Task { @MainActor in
            setupVideoLayer()
            if !isHintPresented {
                configureFoodDetection()
            }
        }
    }

    func setupVideoLayer() {
        guard videoLayer == nil else { return }
        if let vLayer = passioSDK.getPreviewLayerWithGravity(volumeDetectionMode: volumeDetectionMode,
                                                             videoGravity: .resizeAspectFill) {
            videoLayer = vLayer
            let bgFrame = previewView.bounds
            vLayer.frame = bgFrame
            previewView.layer.insertSublayer(vLayer, at: 0)

            zoomSlider.minimumValue = Float(passioSDK.getMinMaxCameraZoomLevel.minLevel ?? 0)
            zoomSlider.maximumValue = 10 // Float(passioSDK.getMinMaxCameraZoomLevel.maxLevel ?? 0)
        }
    }

    func startFoodDetection(with configuration: FoodDetectionConfiguration) {
        addTapGestureForFocus()
        isRecognitionsPaused = false

        Task.detached(priority: .userInitiated) { [weak self] () in
            guard let self else { return }
            passioSDK.startFoodDetection(detectionConfig: configuration,
                                              foodRecognitionDelegate: self) { (ready) in
                if !ready {
                    print("SDK was not configured correctly \(self.passioSDK.status)")
                }
            }
        }
    }

    func startNutritionFactsDetection() {

        isRecognitionsPaused = false

        Task.detached(priority: .userInitiated) { [weak self] () in
            guard let self else { return }
            self.passioSDK.startNutritionFactsDetection(nutritionfactsDelegate: self) { isReady in
                if !isReady {
                    print("Nutrition Facts not available \(self.passioSDK.status)")
                }
            }
        }
    }

    func pauseDetection() {
        passioSDK.stopFoodDetection()
        isRecognitionsPaused = true
    }

    func stopDetection() {
        passioSDK.stopFoodDetection()
        isRecognitionsPaused = true
        foodDetectedView.isHidden = true
        nutritionDetectedView.isHidden = true
    }

    func startLoading() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    func endLoading() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

// MARK: - FoodRecognition Delegate
extension FoodRecognitionV3ViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?, image: UIImage?) {

        guard !isRecognitionsPaused,
              !isHintPresented,
              videoLayer != nil,
              (foodResultVC?.containerViewHeightConstraint?.constant ?? -1) == 0 else {
            return
        }

        // Barcode
        if let barcode = candidates?.barcodeCandidates?.first {
            dataset = BarcodeDataSet(candidate: barcode)
            return
        }

        // PackagedFood
        if let candidate = candidates?.packagedFoodCandidates?.first {
            dataset = PackageFoodDataSet(candidate: candidate)
            return
        }

        // Normal Food
        if let firstCandidate = candidates?.detectedCandidates.first,
           firstCandidate.passioID != "BKG0001" {
            var _tempArray = candidates?.detectedCandidates ?? []
            _tempArray.remove(at: 0)
            dataset = VisualFoodDataSet(candidate: firstCandidate,topKResults: _tempArray)
            return
        }

        if tempDataset != nil {
            tempDataset = nil
        }
    }
}

// MARK: - NutritionFacts Delegate
extension FoodRecognitionV3ViewController: NutritionFactsDelegate {

    func recognitionResults(nutritionFacts: PassioNutritionFacts?, text: String?) {

        if let nutritionFacts = nutritionFacts, nutritionFacts.foundNutritionFactsLabel {
            dataset = NutritionFactsDataSet(nutritionFacts: nutritionFacts)
            return
        }
    }
}

// MARK: - DetectedFoodResultView Delegate
extension FoodRecognitionV3ViewController: DetectedFoodResultViewDelegate {
    
    func didTapOnAddIngredient(dataset: (any FoodRecognitionDataSet)?) {
        pauseDetection()
        
        if let dataset = dataset as? FoodRecognitionDataSetConnector {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] () in
                guard let self else { return }
                dataset.getRecordV3(dataType: dataset) { foodRecordV3 in
                    if let foodRecordV3 = foodRecordV3 {
                        self.navigateToRecipeDelegate?.onNavigateToFoodRecipe(with: foodRecordV3)
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        dataset.getFoodItem { passioFoodItem in
                            if let passioFoodItem = passioFoodItem {
                                self.navigateToRecipeDelegate?.onNavigateToFoodRecipe(with: FoodRecordV3(foodItem: passioFoodItem))
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                }
            })
        }
    }
    

    func didScannedWrongBarcode() {
        stopDetection()
        let popup = FoodRecognisationPopUpController.present(on: navigationController,
                                                             launchOption: .barcodeFailure)
        popup.delegate = self
    }

    func didTapOnAddManual() {
        let vc = TextSearchViewController()
        vc.advancedSearchDelegate = self
        if resultViewFor == .addIngredient {
            vc.isCreateRecipe = true
        }
        else {
            vc.shouldPopVC = false
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapOnEdit(dataset: (any FoodRecognitionDataSet)?) {

        pauseDetection()

        if let dataset = dataset as? FoodRecognitionDataSetConnector {
            dataset.getRecordV3(dataType: dataset) { [weak self] record in
                guard let self else { return }
                guard let record = record else {
                    configureFoodDetection()
                    return
                }
                if resultViewFor == .addLog {
                    navigateToEditViewContorller(record)
                }
                else {
                    navigateToEditIngredientViewContorller(record)
                }
            }
        }
    }

    func didTaponAlternative(dataset: (any FoodRecognitionDataSet)?) {

        if let dataset = dataset as? FoodRecognitionDataSetConnector {

            dataset.getRecordV3(dataType: dataset) { [weak self] record in

                guard let self else { return }
                guard var record = record else {
                    configureFoodDetection()
                    return
                }
                record.createdAt = Date()
                record.mealLabel = MealLabel.mealLabelBy()
                if resultViewFor == .addIngredient {
                    self.navigateToRecipeDelegate?.onNavigateToFoodRecipe(with: record)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    PassioInternalConnector.shared.updateRecord(foodRecord: record)
                    DispatchQueue.main.async {
                        self.showMessage(msg: ToastMessages.addedToLog, alignment: .center)
                    }
                }
            }
        }
    }

    func didTapOnLog(dataset: (any FoodRecognitionDataSet)?) {

        startLoading()
        pauseDetection()

        if let dataset = dataset as? FoodRecognitionDataSetConnector {
            
            dataset.getRecordV3(dataType: dataset) { [weak self] record in
                guard let self else { return }
                endLoading()

                guard let record = record else {
                    configureFoodDetection()
                    return
                }
                stopDetection()

                if resultViewFor == .addIngredient {
                    self.navigateToRecipeDelegate?.onNavigateToFoodRecipe(with: record)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    var newFoodRecord = record
                    newFoodRecord.uuid = UUID().uuidString
                    newFoodRecord.createdAt = Date()
                    newFoodRecord.mealLabel = MealLabel.mealLabelBy(time: Date())
                    connector.updateRecord(foodRecord: newFoodRecord)
                    
                    let popup = FoodRecognisationPopUpController.present(on: self.navigationController,
                                                                         launchOption: .loggedSuccessfully)
                    popup.delegate = self
                }
            }
        }
    }

    func didViewExpanded(isExpanded: Bool) {
        if isExpanded {
            sendCameraViewToBack(isSendBack: true)
            pauseDetection()
        } else {
            sendCameraViewToBack(isSendBack: false)
            configureFoodDetection()
        }
    }

    func didViewStartedDragging(isDragging: Bool) {
        if isDragging {
            sendCameraViewToBack(isSendBack: true)
        }
    }
}

// MARK: - DetectedNutriFactResultViewController Delegate
extension FoodRecognitionV3ViewController: DetectedNutriFactResultViewControllerDelegate {

    func onClickNext(dataset: NutritionFactsDataSet) {
        
        if resultViewFor == .addIngredient {
            pauseDetection()
            stopDetection()
            self.navigationController?.popViewController(animated: true)
        }
        else {
            pauseDetection()
            let createFoodVC = CreateFoodViewController()
            createFoodVC.vcTitle = "Edit Nutrition Facts"
            createFoodVC.isFromNutritionFacts = true
            createFoodVC.foodDataSet = dataset
            createFoodVC.navigateToMyFoodsDelegate = self
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] () in
                guard let self else { return }
                navigationController?.pushViewController(createFoodVC, animated: true)
            })
        }
    }

    func renameFoodRecordAlert(dataset: NutritionFactsDataSet) { }

    func onClickCancel() {
        dataset = nil
        configureFoodDetection()
    }

    func didNutriFactViewExpanded(isExpanded: Bool) {
        isExpanded ? pauseDetection() : configureFoodDetection()
    }
}

// MARK: - DetectedNutriFactResultViewController Delegate
extension FoodRecognitionV3ViewController: NavigateToMyFoodsDelegate {

    func onNavigateToMyFoods() {
        navigateToMyFoodsDelegate?.onNavigateToMyFoods()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - FoodRecognisationPopUp Delegate
extension FoodRecognitionV3ViewController: FoodRecognisationPopUpDelegate {

    func didAskForNutritionScanBarcodeFailure() {
        startNutritionFactsDetection()
    }

    func didAskNavigateToDiary() {
        NutritionUICoordinator.navigateToDairyAfterAction(navigationController: navigationController)
    }

    func didAskContinueScanning() {
        configureFoodDetection()
    }

    func didCancelOnBarcodeFailure() { }
}

// MARK: - AdvancedTextSearchView Delegate
extension FoodRecognitionV3ViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {
        guard let foodRecord = record else { return }
        if resultViewFor == .addIngredient {
            if isPlusAction {
                self.navigateToRecipeDelegate?.onNavigateToFoodRecipe(with: foodRecord)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.navigateToEditIngredientViewContorller(foodRecord)
            }
        }
        else {
            navigateToEditViewContorller(foodRecord)
        }
    }

    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool) {
        guard let foodItem = item else { return }
        let foodRecord = FoodRecordV3(foodItem: foodItem)
        if resultViewFor == .addIngredient {
            if isPlusAction {
                self.navigateToRecipeDelegate?.onNavigateToFoodRecipe(with: foodRecord)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.navigateToEditIngredientViewContorller(foodRecord)
            }
        }
        else {
            navigateToEditViewContorller(foodRecord)
        }
    }

    private func navigateToEditViewContorller(_ record: FoodRecordV3) {

        let editVC = FoodDetailsViewController()
        editVC.foodRecord = record

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] () in
            guard let self else { return }
            navigationController?.pushViewController(editVC, animated: true)
        })
    }
    
    private func navigateToEditIngredientViewContorller(_ record: FoodRecordV3) {
        let editVC = EditIngredientViewController()
        editVC.foodItemData = FoodRecordIngredient(foodRecord: record, entityType: .recipe)
        editVC.indexOfIngredient = 0
        editVC.saveOnDismiss = false
        editVC.indexToPop = 2
        editVC.isAddIngredient = true
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }
}

//MARK: - IngredientEditorViewDelegate
extension FoodRecognitionV3ViewController: IngredientEditorViewDelegate {
    
    func ingredientEditedFoodItemData(ingredient: FoodRecordIngredient, atIndex: Int) {
        var ingredientFood = FoodRecordV3(foodRecordIngredient: ingredient)
        ingredientFood.ingredients = [ingredient]
        self.navigateToRecipeDelegate?.onNavigateToFoodRecipe(with: ingredientFood)
        self.navigationController?.popViewController(animated: true)
    }
}
