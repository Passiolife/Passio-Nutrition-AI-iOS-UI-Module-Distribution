//
//  RotationViewController.swift
//  BaseSDK
//
//  Created by Zvika on 1/7/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import AVFoundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class SuperVideoViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    let passioSDK = PassioNutritionAI.shared
    // let analytics = AnalyticsService.shared
    var volumeDetectionMode = VolumeDetectionMode.auto
    lazy var isFoodLogged = false
    var videoLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            // backgroundImage?.fadeOut(seconds: 0.3)
            // backgroundImage?.isHidden = videoLayer == nil ? false : true
        }
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        backgroundImage?.alpha = 1
////        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated),
////                                               name: UIDevice.orientationDidChangeNotification,
////                                               object: nil)
//        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized { // already authorized
//            setupVideoLayer()
//            startDetection()
//        } else {
//            AVCaptureDevice.requestAccess(for: .video) { (granted) in
//                if granted { // access to video granted
//                    DispatchQueue.main.async {
//                        self.setupVideoLayer()
//                        self.startDetection()
//                    }
//                } else {
//                    print("The user didn't grant access to use camera")
//                }
//            }
//        }
//    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoLayer?.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundImage.fadeIn(seconds: 0.17)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
//        stopDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
        passioSDK.removeVideoLayer()
    }

    // Custom back behavior
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
      //  navigateToDiary(parent: parent, isLogged: isFoodLogged)
    }

//   
//    func stopDetection() {
//        passioSDK.stopFoodDetection()
//    }

    func setupVideoLayer() {
        guard videoLayer == nil else { return }
        print("setupVideoLayer volumeDetectionMode  == \(volumeDetectionMode)" )
        if let vLayer = passioSDK.getPreviewLayerWithGravity(volumeDetectionMode: volumeDetectionMode,
                                                             videoGravity: .resizeAspectFill) {
            videoLayer = vLayer
            vLayer.frame = view.bounds
            view.layer.insertSublayer(vLayer, at: 0)

        }
    }

}
