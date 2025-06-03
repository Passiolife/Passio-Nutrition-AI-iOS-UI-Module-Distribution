//
//  RecogniseBarcodeVC.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 28/05/25.
//

import UIKit
import AVFoundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol RecogniseBarcodeDelegate {
    func detectedBarcode(barcode: String)
    func detectedSystemFood(barcode: String, foodRecord: FoodRecordV3?, isImportData: Bool)
    func detectedCustomFood(barcode: String, foodRecord: FoodRecordV3?, isEditExisting: Bool)
}

class RecogniseBarcodeVC: UIViewController {

    enum State {
        case detecting
        case userFood
        case systemFood
    }
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var zoomSlider: UISlider!

    @IBOutlet weak var popupContainer: UIStackView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    private let passioSDK = PassioNutritionAI.shared
    private var videoLayer: AVCaptureVideoPreviewLayer?
    
    var barcodeDelegate: RecogniseBarcodeDelegate?
    private var foodRecord: FoodRecordV3?
    private var isUserFoodBarcode: Bool = false
    var state: State = .detecting
    var barcodeValue: String = ""
    
    var barcodeSystemTitle: String = "Barcode Already In System"
    var barcodeSystemDesc: String = "This barcode matches an existing item in our database. You can import data from an existing item, or use only the barcode with your own custom data."
    var barcodeSystemLeftButton: String = "Import Existing Data"
    var barcodeSystemRightButton: String = "Use Barcode Only"
    
    var customFoodTitle: String = "Custom Food Already Exists"
    var customFoodDesc: String = "This barcode matches an existing item in your custom food list. You can edit the existing item, or create a new Item without the barcode."
    var customFoodLeftButton: String = "Edit Existing Item"
    var customFoodRightButton: String = "Create New Item"
    
    private var isFocusEnabled = false {
        didSet {
            let msg = isFocusEnabled ? "On" : "Off"
            showMessage(msg: "Focus: \(msg)", duration: 0.35)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        passioSDK.stopFoodDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
        passioSDK.removeVideoLayer()
    }
    
    func basicSetup() {
        title = "Barcode Scanner"
        setupBackButton()
        navigationController?.isNavigationBarHidden = false
        zoomSlider.minimumTrackTintColor = .primaryColor
        zoomSlider.maximumTrackTintColor = UIColor.white.alpha(0.35)
    }
    
    func checkPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            startRecognition()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.startRecognition()
                } else {
                    print("The user didn't grant access to use camera")
                }
            }
        }
    }
    
    func startRecognition() {
        DispatchQueue.main.async {
            self.setupVideoLayer()
            self.startDetection()
        }
    }
    
    func setupVideoLayer() {
        guard videoLayer == nil else { return }
        if let vLayer = passioSDK.getPreviewLayerWithGravity(videoGravity: .resizeAspectFill) {
            videoLayer = vLayer
            let bgFrame = previewView.bounds
            vLayer.frame = bgFrame
            previewView.layer.insertSublayer(vLayer, at: 0)
        }
    }
    
    func startDetection() {
        addTapGestureForFocus()
        let detectionConfig = FoodDetectionConfiguration(detectVisual: true,
                                                         detectBarcodes: true,
                                                         detectPackagedFood: true)
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            self.passioSDK.startFoodDetection(detectionConfig: detectionConfig,
                                              foodRecognitionDelegate: self) { ready in
                if !ready { print("SDK was not configured correctly \(self.passioSDK.status)") }
            }
        }
    }
    
    func updateUI() {
        switch state {
        case .detecting:
            controlsView.isHidden = false
            popupContainer.isHidden = true
            
        default:
            controlsView.isHidden = true
            popupContainer.isHidden = false
            
            titleLabel.text = (state == .systemFood) ? barcodeSystemTitle : customFoodTitle
            descLabel.text = (state == .systemFood) ? barcodeSystemDesc : customFoodDesc
            leftButton.setTitle(state == .systemFood ? barcodeSystemLeftButton : customFoodLeftButton, for: .normal)
            rightButton.setTitle(state == .systemFood ? barcodeSystemRightButton : customFoodRightButton, for: .normal)
        }
    }
    
    @IBAction func onZooming(_ sender: UISlider) {
        guard let _ = videoLayer else { return }
        if sender.value < 1 { return }
        passioSDK.setCamera(toVideoZoomFactor: CGFloat(sender.value))
    }
    
    private func addTapGestureForFocus() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapToFocus))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onTapToFocus(_ gesture: UITapGestureRecognizer) {
        guard let videoLayer = videoLayer, isFocusEnabled else { return }
        let tappedPoint = gesture.location(in: view)
        let convertedPoint = videoLayer.captureDevicePointConverted(fromLayerPoint: tappedPoint)
        passioSDK.setTapToFocus(pointOfInterest: convertedPoint)
    }
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        if self.state == .systemFood {
            barcodeDelegate?.detectedSystemFood(barcode: barcodeValue,
                                                foodRecord: self.foodRecord,
                                                isImportData: true)
        } else if self.state == .userFood {
            barcodeDelegate?.detectedCustomFood(barcode: barcodeValue,
                                                foodRecord: self.foodRecord,
                                                isEditExisting: true)
        }
        self.pop()
    }
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        if self.state == .systemFood {
            barcodeDelegate?.detectedSystemFood(barcode: barcodeValue,
                                                foodRecord: self.foodRecord,
                                                isImportData: false)
        } else if self.state == .userFood {
            barcodeDelegate?.detectedCustomFood(barcode: barcodeValue,
                                                foodRecord: self.foodRecord,
                                                isEditExisting: false)
        }
        self.pop()
    }
}

extension RecogniseBarcodeVC: FoodRecognitionDelegate {
    
    func recognitionResults(candidates: FoodCandidates?, image: UIImage?) {
        guard state == .detecting else { return }
        guard videoLayer != nil else { return }
        guard let barcode = candidates?.barcodeCandidates?.first else { return }
        barcodeDetected(barcode)
    }
}

extension RecogniseBarcodeVC {
    
    func barcodeDetected(_ barcode: BarcodeCandidate) {
        
        let dataset = BarcodeDataSet(candidate: barcode)
        dataset.getFoodItem(completion: { [weak self] passioFoodItem in
            guard let self else { return }
            
            // Local User Food Barcode
            if let barcodeFoodRecord = dataset.foodRecord {
                foodRecord = barcodeFoodRecord
                barcodeValue = barcode.value
                isUserFoodBarcode = true
                self.state = .userFood
            }
            // SDK Barcode
            else if let foodItem = passioFoodItem {
                foodRecord = FoodRecordV3(foodItem: foodItem)
                barcodeValue = barcode.value
                isUserFoodBarcode = false
                self.state = .systemFood
            }
            else {
                barcodeValue = barcode.value
                isUserFoodBarcode = false
                self.barcodeDelegate?.detectedBarcode(barcode: barcode.value)
                self.pop()
            }
            self.updateUI()
        })
    }
}
