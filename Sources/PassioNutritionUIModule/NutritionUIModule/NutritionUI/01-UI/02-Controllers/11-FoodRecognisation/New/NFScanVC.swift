//
//  NFScanVC.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 21/05/25.
//

import UIKit

class NFScanVC: UIViewController {
    
    @IBOutlet private weak var cameraView: CameraView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupCamera()
        
        // Temp
        let image = UIImage.imageFromBundle(named: "NF1")
        if let image = image {
            fetchData(image: image)
        } else {
            print("No image")
        }
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
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NFScanVC: CameraViewDelegate {
    func didCaptureImage(image: UIImage?, error: Error?) {
        guard let image = image else { return }
        fetchData(image: image)
    }
}
