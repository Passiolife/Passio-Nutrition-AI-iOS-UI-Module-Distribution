//
//  NFFetchDataVC.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 21/05/25.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class NFFetchDataVC: UIViewController {

    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var viewAnalysing: UIView!
    @IBOutlet weak var viewItemSaved: UIView!

    var capturedImage: UIImage? = nil
    private let PassioSDK = PassioNutritionAI.shared

    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        getNutritionFacts()
    }
    
    func basicSetup() {
        progressBar.trackColor = .white
        progressBar.progressColor = .primaryColor
        progressBar.layer.borderColor = UIColor.primaryColor.cgColor
        progressBar.layer.borderWidth = 2
        capturedImageView.image = capturedImage

        setupBackButton()
        self.title = "Photo Preview"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func startProgress() {
        progressBar.progress = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.05,
            target: self,
            selector: #selector(updateProgress),
            userInfo: nil,
            repeats: true
        )
    }
    
    func pauseProgress() {
        timer?.invalidate()
        timer = nil
    }
    
    func finishProgress() {
        progressBar.progress = 1
        timer?.invalidate()
        timer = nil
    }
    
    func getNutritionFacts() {
        updateUI(isAnalysing: true)
        guard let image = capturedImage else { return }
        startProgress()
        PassioSDK.recognizeNutritionFactsRemote(image: image, resolution: .res_1080) { passioFoodItem in
            MainQueue {
                self.finishProgress()
                Delay(0.45) {
                    self.didReceiveResult(foodItem: passioFoodItem)
                }
            }
        }
    }
    
    func didReceiveResult(foodItem: PassioFoodItem?) {
        guard let foodItem = foodItem else {
            showNoDataFound()
            return
        }
        guard foodItem.hasNutritionFacts else {
            showNoDataFound()
            return
        }
        let foodRecord = FoodRecordV3(foodItem: foodItem)
        navigateToEditData(foodRecord: foodRecord)
    }
    
    func navigateToEditData(foodRecord: FoodRecordV3? = nil) {
        let vc = NFEditDataVC.load(storyboard: .SCAN)
        vc.foodRecord = foodRecord
        vc.capturedImage = self.capturedImage
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.present(navigationController)
        vc.onSave = {
            self.onSave()
        }
        vc.onCancel = {
            self.onCancel()
        }
    }
    
    func onSave() {
        updateUI(isAnalysing: false)
    }
    
    func onCancel() {
        self.pop()
    }
    
    func updateUI(isAnalysing: Bool) {
        if isAnalysing {
            viewAnalysing.isHidden = false
            viewItemSaved.isHidden = true
        } else {
            viewAnalysing.isHidden = true
            viewItemSaved.isHidden = false
        }
    }
    
    @IBAction func viewDiaryTapped(_ sender: UIButton) {
        NutritionUICoordinator.navigateToDairyAfterAction(navigationController: self.navigationController)
    }
    
    @IBAction func AddMoreTapped(_ sender: UIButton) {
        self.navigationController?.popToSpecificViewController(BarcodeScanVC.self, isAnimated: true)
    }
    
    @objc func updateProgress() {
        let progress = progressBar.progress
        if progress < 0.9 {
            progressBar.progress += 0.005
        } else {
            pauseProgress()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showNoDataFound() {
        let vc = NFNoDataVC.load(storyboard: .SCAN)
        self.present(vc)
        
        vc.onTryAgain = {
            Delay(0.65) {
                self.tryAgain()
            }
        }
        vc.onEnterManually = {
            Delay(0.65) {
                self.enterManually()
            }
        }
    }
    
    func tryAgain() {
        self.pop()
    }
    
    func enterManually() {
        navigateToEditData()
    }
}

extension PassioFoodItem {
    
    var hasNutritionFacts: Bool {
        self.hasFullMacros && self.hasServingSize
    }
    
    var hasFullMacros: Bool {
        let nutrients = self.nutrientsReference()
        if nutrients.calories() != nil &&
            nutrients.carbs() != nil &&
            nutrients.protein() != nil &&
            nutrients.fat() != nil {
            return true
        } else {
            return false
        }
    }
    
    var hasServingSize: Bool {
        self.amount.selectedQuantity > 0 &&
        !self.amount.selectedUnit.isEmpty
    }
}
