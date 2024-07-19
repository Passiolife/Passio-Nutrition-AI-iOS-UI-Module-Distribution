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

    @IBOutlet weak var flashLightButton: UIButton!
    @IBOutlet weak var focusButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var scanningView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nutritionContentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var zoomSlider: UISlider!

    private let passioSDK = PassioNutritionAI.shared
    private let connector = PassioInternalConnector.shared
    private var volumeDetectionMode = VolumeDetectionMode.none
    private var videoLayer: AVCaptureVideoPreviewLayer?
    private var timer: Timer?
    private var isRecognitionsPaused = false
    private var currentZoomLevel: CGFloat = 1
    private var workItem: DispatchWorkItem?

    public var dataset: (any FoodRecognitionDataSet)? {
        didSet {
            Task { @MainActor in
                if dataset != nil {
                    tempDataset = dataset
                }
                if let dataset = dataset as? NutritionFactsDataSet {
                    nutritionContentView.isHidden = false
                    contentView.isHidden = true
                    nutritionFactResultVC?.updateDataset(dataset)
                } else {
                    nutritionContentView.isHidden = true
                    contentView.isHidden = false
                    foodResultVC?.updateDataSet(newDataSet: dataset)
                }
                scanningView.isHidden = true
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
            let msg = isFocusEnabled ? "On" : "Off"
            showMessage(msg: "Tap to Focus: \(msg)",
                        duration: 0.35,
                        width: 200,
                        alignment: .center)
        }
    }
    private var isHintPresented: Bool = false {
        didSet {
            if isHintPresented {
                pauseDetection()
            } else {
                dataset = nil
                startFoodDetection()
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
        foodResultVC?.delegate = self
        nutritionFactResultVC?.delegate = self
        activityIndicator.color = .primaryColor
        zoomSlider.minimumTrackTintColor = .primaryColor
        flashLightButton.tintColor = .primaryColor
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

        //This is timer which is for just checking peridically due to tray issue
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            if isRecognitionsPaused {
                if (foodResultVC?.containerViewHeightConstraint?.constant ?? -1) == 0
                    && presentedViewController == nil  {
                    startFoodDetection()
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

    @IBAction func onZoomLevelChanged(_ sender: UISlider) {
        guard let _ = videoLayer else { return }
        if sender.value < 1 { return }
        passioSDK.setCamera(toVideoZoomFactor: CGFloat(sender.value))
    }

    @objc func presentHint() {
        stopDetection()
        isHintPresented = true
        ScanningHintViewController.presentHint(presentigVC: navigationController) { [weak self] in
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
        passioSDK.setFlashlightOn()
    }
}

// MARK: - Helper methods: Food Detection
private extension FoodRecognitionV3ViewController {

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
                startFoodDetection()
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
        }
    }

    func startFoodDetection() {
        addTapGestureForFocus()
        isRecognitionsPaused = false
        let detectionConfig = FoodDetectionConfiguration(detectVisual: true,
                                                         volumeDetectionMode: volumeDetectionMode,
                                                         detectBarcodes: true,
                                                         detectPackagedFood: true)

        Task.detached(priority: .userInitiated) { [weak self] () in
            guard let self else { return }
            self.passioSDK.startFoodDetection(detectionConfig: detectionConfig,
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
        scanningView.isHidden = true
        contentView.isHidden = true
        nutritionContentView.isHidden = true
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

    func didScannedWrongBarcode() {
        stopDetection()
        let popup = FoodRecognisationPopUpController.present(on: navigationController,
                                                             launchOption: .barcodeFailure)
        popup.delegate = self
    }

    func didTapOnAddManual() {
        let vc = TextSearchViewController()
        vc.advancedSearchDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapOnEdit(dataset: (any FoodRecognitionDataSet)?) {

        pauseDetection()

        if let dataset = dataset as? FoodRecognitionDataSetConnector {
            dataset.getRecordV3 { [weak self] record in
                guard let self else { return }
                guard let record = record else {
                    self.startFoodDetection()
                    return
                }
                self.navigateToEditViewContorller(record)
            }
        }
    }

    func didTaponAlternative(dataset: (any FoodRecognitionDataSet)?) {

        if let dataset = dataset as? FoodRecognitionDataSetConnector {

            dataset.getRecordV3 { [weak self] record in

                guard let self else { return }
                guard var record = record else {
                    self.startFoodDetection()
                    return
                }
                record.createdAt = Date()
                record.mealLabel = MealLabel.mealLabelBy()
                PassioInternalConnector.shared.updateRecord(foodRecord: record, isNew: true)
                DispatchQueue.main.async {
                    self.showMessage(msg: "Added to log", alignment: .center)
                }
            }
        }
    }

    func didTapOnLog(dataset: (any FoodRecognitionDataSet)?) {

        startLoading()
        pauseDetection()

        if let dataset = dataset as? FoodRecognitionDataSetConnector {
            
            dataset.getRecordV3 { [weak self] record in
                guard let `self` = self else { return }
                self.endLoading()

                guard let record = record else {
                    self.startFoodDetection()
                    return
                }
                self.stopDetection()

                var newFoodRecord = record
                newFoodRecord.uuid = UUID().uuidString
                newFoodRecord.createdAt = Date()
                newFoodRecord.mealLabel = MealLabel.mealLabelBy(time: Date())
                connector.updateRecord(foodRecord: newFoodRecord, isNew: true)

                let popup = FoodRecognisationPopUpController.present(on: self.navigationController,
                                                                     launchOption: .loggedSuccessfully)
                popup.delegate = self
            }
        }
    }

    func didViewExpanded(isExpanded: Bool) {
        if isExpanded {
            pauseDetection()
        } else {
            startFoodDetection()
        }
    }
}

// MARK: - DetectedNutriFactResultViewController Delegate
extension FoodRecognitionV3ViewController: DetectedNutriFactResultViewControllerDelegate {

    func onClickNext(dataset: NutritionFactsDataSet) {

        pauseDetection()

        let createFoodVC = CreateFoodViewController()
        createFoodVC.isFromNutritionFacts = true
        createFoodVC.foodDataSet = dataset

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] () in
            guard let self else { return }
            navigationController?.pushViewController(createFoodVC, animated: true)
        })
    }

    func renameFoodRecordAlert(dataset: NutritionFactsDataSet) { }

    func onClickCancel() {
        dataset = nil
        startFoodDetection()
    }

    func didNutriFactViewExpanded(isExpanded: Bool) {
        isExpanded ? pauseDetection() : startFoodDetection()
    }
}

// MARK: - FoodRecognisationPopUp Delegate
extension FoodRecognitionV3ViewController: FoodRecognisationPopUpDelegate {

    func didCancelOnBarcodeFailure() {

    }

    func didAskForNutritionScanBarcodeFailure() {
        startNutritionFactsDetection()
    }

    func didAskNavigateToDiary() {
        NutritionUICoordinator.navigateToDairyAfterAction(navigationController: navigationController)
    }

    func didAskContinueScanning() {
        startFoodDetection()
    }
}

// MARK: - AdvancedTextSearchView Delegate
extension FoodRecognitionV3ViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {
        guard let foodRecord = record else { return }
        navigateToEditViewContorller(foodRecord)
    }

    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool) {
        guard let foodItem = item else { return }
        let foodRecord = FoodRecordV3(foodItem: foodItem)
        navigateToEditViewContorller(foodRecord)
    }

    private func navigateToEditViewContorller(_ record: FoodRecordV3) {

        let editVC = EditRecordViewController()
        editVC.foodRecord = record

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] () in
            guard let self else { return }
            navigationController?.pushViewController(editVC, animated: true)
        })
    }
}
