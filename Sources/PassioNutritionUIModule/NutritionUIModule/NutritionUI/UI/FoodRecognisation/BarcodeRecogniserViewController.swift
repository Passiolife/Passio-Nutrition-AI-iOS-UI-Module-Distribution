//
//  BarcodeRecogniserViewController.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 15/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
import AVFoundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

final class BarcodeRecogniserViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var barcodeDetectedStackView: UIStackView!
    @IBOutlet weak var barcodeTextField: UITextField!
    @IBOutlet weak var barcodeStackVwBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scanGuideView: UIView!
    @IBOutlet weak var barcodeInSystemView: UIView!

    private let passioSDK = PassioNutritionAI.shared
    private var videoLayer: AVCaptureVideoPreviewLayer?
    private var foodRecord: FoodRecordV3?
    private var isRecognitionsPaused = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let self else { return }
                self.backgroundView.backgroundColor = self.isRecognitionsPaused ? .black.withAlphaComponent(0.62) : .clear
            })
        }
    }
    private var isFocusEnabled = false {
        didSet {
            let msg = isFocusEnabled ? "On" : "Off"
            showMessage(msg: "Focus: \(msg)", duration: 0.35)
        }
    }

    var barcodeValue: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        barcodeDetectedStackView.isHidden = true
        barcodeTextField.delegate = self

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        passioSDK.stopFoodDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
        passioSDK.removeVideoLayer()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: @IBAction
    @IBAction func onFocusTapped(_ sender: UIButton) {
        isFocusEnabled.toggle()
    }

    @IBAction func onZooming(_ sender: UISlider) {
        guard let _ = videoLayer else { return }
        if sender.value < 1 { return }
        passioSDK.setCamera(toVideoZoomFactor: CGFloat(sender.value))
    }

    @IBAction func onConfirmBarcode(_ sender: UIButton) {
        barcodeValue?(barcodeTextField.text ?? "")
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onCancelBarcode(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onViewSystemBarcode(_ sender: UIButton) {
        guard let foodRecord else { return }
        let editVC = EditRecordViewController()
        editVC.foodRecord = foodRecord
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] () in
            guard let self else { return }
            navigationController?.pushViewController(editVC, animated: true)
        })
    }
}

// MARK: - Helper
extension BarcodeRecogniserViewController {

    private func setupNavigation() {
        title = "Barcode Scanner"
        setupBackButton()
        navigationController?.isNavigationBarHidden = false
    }

    private func setupVideoAndStartDetection() {
        DispatchQueue.main.async {
            self.setupVideoLayer()
            self.startDetection()
        }
    }

    func setupVideoLayer() {
        guard videoLayer == nil else { return }
        if let vLayer = passioSDK.getPreviewLayerWithGravity(volumeDetectionMode: .none,
                                                             videoGravity: .resizeAspectFill) {
            videoLayer = vLayer
            let bgFrame = previewView.bounds
            vLayer.frame = bgFrame
            previewView.layer.insertSublayer(vLayer, at: 0)
        }
    }

    func startDetection() {
        addTapGestureForFocus()
        isRecognitionsPaused = false
        let detectionConfig = FoodDetectionConfiguration(detectVisual: true,
                                                         volumeDetectionMode: .none,
                                                         detectBarcodes: true,
                                                         detectPackagedFood: true)
        DispatchQueue.global(qos: .userInteractive).async { [weak self] () in
            guard let self else { return }
            self.passioSDK.startFoodDetection(detectionConfig: detectionConfig,
                                              foodRecognitionDelegate: self) { (ready) in
                if !ready {
                    print("SDK was not configured correctly \(self.passioSDK.status)")
                }
            }
        }
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

    @objc private func keyboardWillShow(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification,
                             viewBottomConstraint: barcodeStackVwBottomConstraint,
                             keyboardWillShow: true)
    }

    @objc private func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification,
                             viewBottomConstraint: barcodeStackVwBottomConstraint,
                             keyboardWillShow: false)
    }

    private func moveViewWithKeyboard(notification: NSNotification,
                                      viewBottomConstraint: NSLayoutConstraint,
                                      keyboardWillShow: Bool) {

        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let keyboardCurve = UIView.AnimationCurve(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        viewBottomConstraint.constant = keyboardWillShow ? keyboardHeight : 20
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}

// MARK: - FoodRecognitionDelegate
extension BarcodeRecogniserViewController: FoodRecognitionDelegate {

    // TODO: Fix Nutrition Facts
    func recognitionResults(candidates: FoodCandidates?, image: UIImage?) {

        guard !isRecognitionsPaused, videoLayer != nil else { return }

        if let barcode = candidates?.barcodeCandidates?.first {

            checkInSystemBarcodeAvailable(dataset: BarcodeDataSet(candidate: barcode)) { (inSystem) in

                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    scanGuideView.isHidden = true
                    barcodeInSystemView.isHidden = inSystem ? false : true
                    barcodeDetectedStackView.isHidden = inSystem ? true : false
                    barcodeTextField.text = inSystem ? "" : barcode.value
                }
            }
        }
    }

    private func checkInSystemBarcodeAvailable(dataset: BarcodeDataSet,
                                               completion: @escaping (Bool) -> Void) {
        dataset.getFoodItem(completion: { [weak self] (passioFoodItem) in
            guard let self else { return }
            if let foodItem = passioFoodItem {
                foodRecord = FoodRecordV3(foodItem: foodItem) // SDK Barcode
                completion(true)
            } else if let barcodeFoodRecord = dataset.foodRecord { // Local User Food Barcode
                foodRecord = barcodeFoodRecord
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}

// MARK: - UITextField Delegate
extension BarcodeRecogniserViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        isRecognitionsPaused = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        isRecognitionsPaused = false
        return true
    }
}
