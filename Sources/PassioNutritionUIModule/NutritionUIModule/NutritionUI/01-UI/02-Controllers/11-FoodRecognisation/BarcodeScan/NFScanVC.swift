//
//  NFScanVC.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 21/05/25.
//

import UIKit
import AVFoundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class NFScanVC: UIViewController {
    
    @IBOutlet private weak var cameraView: CameraView!

    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        setupCamera()
    }
    
    func basicSetup() {
        setupBackButton()
        self.title = "Barcode Scan"
        self.navigationController?.isNavigationBarHidden = false
        let rightButton = UIBarButtonItem(image: UIImage.imageFromBundle(named: "hint_icon"), style: .plain, target: self, action: #selector(presentHint))
        rightButton.tintColor = UIColor.gray400
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func presentHint() {
        self.showTip(for: .captureNutritionFacts)
    }
    
    func setupCamera() {
        self.cameraView.delegate = self
        self.cameraView.startCamera { granted in
            if !granted {
                self.showPermissionAlert()
            }
        }
    }
    
    func showPermissionAlert() {
        self.showAlert(title: "Camera Access Denied",
                       message: "Enable camera access in Settings.") {
            print("Go to Settings App...")
        }
    }
    
    func fetchData(image: UIImage) {
        let vc = NFFetchDataVC.load(storyboard: .SCAN)
        vc.capturedImage = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NFScanVC: CameraViewDelegate {
    func didCaptureImage(image: UIImage?, error: Error?) {
        guard let image = image else { return }
        fetchData(image: image)
    }
}
