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

    var capturedImage: UIImage? = nil
    private let PassioSDK = PassioNutritionAI.shared

    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        getNutritionFacts()
//        Delay(2) {
//            self.showNoDataFound()
//        }
    }
    
    func basicSetup() {
        progressBar.trackColor = .white
        progressBar.progressColor = .primaryColor
        progressBar.layer.borderColor = UIColor.primaryColor.cgColor
        progressBar.layer.borderWidth = 2
        capturedImageView.image = capturedImage

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
        printAny(foodItem)
        
        if let foodItem {
            let foodRecord = FoodRecordV3(foodItem: foodItem)
            let vc = NFEditDataVC.load(storyboard: .SCAN)
            vc.foodRecord = foodRecord
            vc.capturedImage = self.capturedImage
            self.present(vc)
        } else {
            print("No data found")
        }
    }
    
    func printTest() {
        
    }
    
    func done() {
        self.showAlert(title: "Done")
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
        self.pop()
    }
}
