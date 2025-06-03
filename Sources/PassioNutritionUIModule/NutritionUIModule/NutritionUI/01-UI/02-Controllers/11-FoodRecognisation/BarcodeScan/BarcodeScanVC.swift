//
//  BarcodeScanVC.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 18/04/25.
//

import UIKit
import AVFoundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class BarcodeScanVC: UIViewController {
    
    enum State {
        case idle
        case scanning
        case detectedFoodItem
        case detectedCustomFood
        case noBarcode
        case addedToLog
    }
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var zoomSlider: PassioSlider!
    @IBOutlet weak var focusButton: UIButton!
    @IBOutlet weak var flashLightButton: UIButton!

    // Scanning
    @IBOutlet weak var scanningView: UIView!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var spinner: CircularSpinner!
    @IBOutlet weak var takePhotoLabel: UILabel!
    
    // Food info view
    @IBOutlet weak var foodInfoView: UIView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var foodImageView: UIImageView!

    // Barcode not recognized
    @IBOutlet weak var noBarcodeView: UIView!
    
    // Added to log
    @IBOutlet weak var logSuccessView: UIView!

    private var videoLayer: AVCaptureVideoPreviewLayer?

    // SDK
    private let passioSDK = PassioNutritionAI.shared
    private var detectionConfig: FoodDetectionConfiguration!
    private let connector = NutritionUIModule.shared

    var detectedBarcode = ""
    var foodItem: PassioFoodItem?
    var foodRecord: FoodRecordV3?
    var isFlashlightOn: Bool = false

    var state: State = .idle {
        didSet {
            didUpdateState()
        }
    }
    
    private var isFocusEnabled = false {
        didSet {
            focusButton.setImage(UIImage(resource: isFocusEnabled ? .focusIcon : .focusOffIcon), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        askCameraPermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        passioSDK.stopFoodDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
        passioSDK.removeVideoLayer()
    }
    
    func basicSetup() {
        self.view.backgroundColor = .white
        setupNavigation()
        configureFoodDetection()
        scanningView.roundCorner(20, top: true)
        foodInfoView.roundCorner(20, top: true)
        
        // Nutrition Facts
        let font = UIFont.system(15, weight: .regular)
        let boldFont = UIFont.system(15, weight: .semibold)
        let nutritionFacts = "Nutrition Facts"
        let fullText = "No Barcode? Take a picture of \(nutritionFacts)"
        let attributedText = NSMutableAttributedString(string: fullText, attributes: [.font: font, .foregroundColor: UIColor.black])
        if let range = fullText.range(of: nutritionFacts) {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttributes([.foregroundColor: UIColor.primaryColor, .font: boldFont], range: nsRange)
        }
        takePhotoLabel.attributedText = attributedText
        spinnerView.backgroundColor = UIColor.rgb(242, 242, 247)
        spinner.color = .primaryColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapToFocus))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        zoomSlider.minimumTrackTintColor = .primaryColor
        zoomSlider.maximumTrackTintColor = UIColor.white.alpha(0.35)
        zoomSlider.tintColor = .white
        
        self.state = .idle
    }
    
    func setupNavigation() {
        self.title = "Barcode Scan"
        setupBackButton()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func configureFoodDetection() {
        self.detectionConfig = FoodDetectionConfiguration(
            detectVisual: false,
            detectBarcodes: true,
            detectPackagedFood: false
        )
    }
    
    fileprivate func askCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted { 
                DispatchQueue.main.async {
                    self?.permissionGranted()
                }
            } else {
                self?.showPermissionAlert()
            }
        }
    }
    
    func showPermissionAlert() {
        self.showAlert(title: "Camera Access Required",
                       message: "Please enable camera access in Settings.") {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func permissionGranted() {
        setupVideoLayer()
        state = .scanning
    }
    
    func setupVideoLayer() {
        
        // The video layer is already set up, so no need to do it again
        if videoLayer != nil { return }
        
        guard let layer = passioSDK.getPreviewLayerWithGravity(videoGravity: .resizeAspectFill) else { return }
        layer.frame = previewView.bounds
        previewView.layer.insertSublayer(layer, at: 0)
        videoLayer = layer
        
        MainQueue {
            self.zoomSlider.minimumValue = Float(self.passioSDK.getMinMaxCameraZoomLevel.minLevel ?? 0)
            self.zoomSlider.maximumValue = 10
        }
    }
    
    func startDetection() {
        
        let zoomValue: Float = 1.5
        zoomSlider.setValue(zoomValue, animated: true)
        passioSDK.setCamera(toVideoZoomFactor: CGFloat(zoomValue))
        
        Delay(0.12) {
            Task.detached(priority: .userInitiated) { [weak self] () in
                guard let self else { return }
                passioSDK.startFoodDetection(detectionConfig: self.detectionConfig,
                                             foodRecognitionDelegate: self) { ready in
                    if !ready {
                        print("SDK was not configured correctly \(self.passioSDK.status)")
                    }
                }
            }
        }
    }
    
    func stopDetection() {
        passioSDK.stopFoodDetection()
    }
    
    // Scanning
    @IBAction func nutritionFactsTapped(_ sender: UIButton) {
        goToNutritionFacts()
    }
    
    // No barcode data
    @IBAction func continueScanTapped(_ sender: UIButton) {
        detectedBarcode = ""
        state = .scanning
    }
    
    @IBAction func takePhotosTapped(_ sender: UIButton) {
        goToNutritionFacts()
    }
    
    // Detected food
    @IBAction func editFoodTapped(_ sender: UIButton) {
        editFood()
    }
    
    @IBAction func logFoodTapped(_ sender: UIButton) {
        logFood()
    }
    
    // Added to Log
    @IBAction func viewDiaryTapped(_ sender: UIButton) {
        NutritionUICoordinator.navigateToDairyAfterAction(navigationController: navigationController)
    }
    
    // Other
    func goToNutritionFacts() {
        let vc = NFScanVC.load(storyboard: .SCAN)
        self.push(vc)
    }
    
    private func navigateToEditViewContorller(_ record: FoodRecordV3) {
        let editVC = FoodDetailsViewController()
        editVC.foodRecord = record
        editVC.isFromBarcodeScan = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] () in
            guard let self else { return }
            navigationController?.pushViewController(editVC, animated: true)
        })
    }
    
    @IBAction func onZoomLevelChanged(_ sender: UISlider) {
        guard let _ = videoLayer else { return }
        if sender.value < 1 { return }
        passioSDK.setCamera(toVideoZoomFactor: CGFloat(sender.value))
    }
    
    @IBAction func onFocusTapped(_ sender: UIButton) {
        isFocusEnabled.toggle()
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
    
    @objc func presentHint() {
        self.showTip(for: .captureNutritionFacts)
    }
}

extension BarcodeScanVC: FoodRecognitionDelegate {
    
    func recognitionResults(candidates: (any FoodCandidates)?, image: UIImage?) {
        guard let barcodeCandidate = candidates?.barcodeCandidates?.first else { return }
        didDetectBarcode(barcodeCandidate)
    }
    
    func didDetectBarcode(_ barcodeCandidate: BarcodeCandidate) {
        let barcode = barcodeCandidate.value
        if barcode == self.detectedBarcode { return }
        self.detectedBarcode = barcode
        self.foodItem = nil
        self.foodRecord = nil
        self.getData()
    }
}

extension BarcodeScanVC {
    
    func getData() {
        getFoodItem(completion: { passioFoodItem in
            if let foodItem = passioFoodItem {
                self.state = .detectedFoodItem
            } else if let foodRecord = self.foodRecord {
                self.state = .detectedCustomFood
            } else {
                self.state = .noBarcode
            }
        })
    }
    
    func getFoodItem(completion: @escaping (PassioFoodItem?) -> Void) {

        self.fetchBarcodeFoodFromLocal() { isUserFoodBarcode in
            if isUserFoodBarcode {
                completion(nil)
            } else {
                self.fetchFoodItem { foodItem in
                    if let foodItem {
                        completion(foodItem)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func fetchBarcodeFoodFromLocal(completion: @escaping (Bool) -> Void) {
        NutritionUIModule.shared.fetchUserFoods(barcode: self.detectedBarcode) { [weak self] barcodeFood in
            guard let self, let barcodeFoodRecord = barcodeFood.first else {
                completion(false)
                return
            }
            self.foodRecord = barcodeFoodRecord
            completion(true)
        }
    }
    
    func fetchFoodItem(completion: @escaping (PassioFoodItem?) -> Void) {
        PassioNutritionAI.shared.fetchFoodItemFor(productCode: self.detectedBarcode) { [weak self] passioFoodItem in
            DispatchQueue.main.async {
                guard let self, let foodItem = passioFoodItem else {
                    completion(nil)
                    return
                }
                self.foodItem = foodItem
                completion(foodItem)
            }
        }
    }
    
    func didUpdateState() {
        switch self.state {
        case .idle:
            scanningView.isHidden = true
            foodInfoView.isHidden = true
            noBarcodeView.isHidden = true
            logSuccessView.isHidden = true
            
        case .scanning:
            scanningView.isHidden = false
            foodInfoView.isHidden = true
            noBarcodeView.isHidden = true
            logSuccessView.isHidden = true
            startDetection()
            
        case .detectedFoodItem, .detectedCustomFood:
            scanningView.isHidden = true
            foodInfoView.isHidden = false
            noBarcodeView.isHidden = true
            logSuccessView.isHidden = true
            
        case .noBarcode:
            scanningView.isHidden = true
            foodInfoView.isHidden = true
            noBarcodeView.isHidden = false
            logSuccessView.isHidden = true
            stopDetection()
        
        case .addedToLog:
            scanningView.isHidden = true
            foodInfoView.isHidden = true
            noBarcodeView.isHidden = true
            logSuccessView.isHidden = false
            stopDetection()
        }
        
        if state == .detectedFoodItem  {
            guard let foodItem = self.foodItem else { return }
            foodNameLabel.text = foodItem.name.capitalized
            barcodeLabel.text = "UPC: " + detectedBarcode
            setImage(foodItem.iconId, entityType: .barcode)
        }
        else if state == .detectedCustomFood  {
            guard let foodItem = self.foodRecord else { return }
            foodNameLabel.text = foodItem.name.capitalized
            barcodeLabel.text = "UPC: " + detectedBarcode
            setImage(foodItem.iconId, entityType: .barcode)
        }
    }
    
    private func setImage(_ passioID: String,
                          entityType: PassioIDEntityType = .item) {
        foodImageView.setFoodImage(id: passioID,
                                   passioID: passioID,
                                   entityType: entityType,
                                   connector: connector) { image in
            DispatchQueue.main.async {
                self.foodImageView.image = image
            }
        }
    }
}

extension BarcodeScanVC {
    
    func startLoading(message: String) {
        self.view.showLoader(message, yInset: 60)
        self.stopDetection()
        self.view.isUserInteractionEnabled = false
    }
    
    func stopLoading() {
        self.view.removeLoader()
        self.view.isUserInteractionEnabled = true
    }
    
    func logFood() {
        startLoading(message: "Logging...")
        self.getRecordV3() { record in
            self.stopLoading()
            guard let record = record else {
                self.state = .scanning
                return
            }
            var newFoodRecord = record
            newFoodRecord.uuid = UUID().uuidString
            newFoodRecord.createdAt = Date()
            newFoodRecord.mealLabel = MealLabel.mealLabelBy(time: Date())
            self.connector.updateRecord(foodRecord: newFoodRecord)
            self.state = .addedToLog
        }
    }
    
    func editFood() {
        startLoading(message: "Fetching...")
        self.getRecordV3() { record in
            self.stopLoading()
            guard let record = record else {
                self.state = .scanning
                return
            }
            self.navigateToEditViewContorller(record)
        }
    }
    
    func getRecordV3(completion: @escaping (FoodRecordV3?) -> Void) {
        
        var barcode = self.detectedBarcode
        if barcode.count == 13 && barcode.first == "0" {
            barcode.removeFirst()
        }
        let entityType: PassioIDEntityType = .barcode
        
        if var foodRecord {
            foodRecord.barcode = barcode
            foodRecord.entityType = entityType
            completion(foodRecord)
            return
        }
        self.getFoodItem { foodItem in
            DispatchQueue.main.async { [self] in
                guard let item = foodItem else {
                    completion(nil)
                    return
                }
                foodRecord = FoodRecordV3(foodItem: item)
                foodRecord?.entityType = entityType
                foodRecord?.barcode = barcode
                completion(foodRecord)
            }
        }
    }
}
