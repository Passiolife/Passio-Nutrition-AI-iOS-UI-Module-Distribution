//
//  RotationViewController.swift
//  BaseSDK
//
//  Created by Zvika on 1/7/22.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
import AVFoundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class RotationViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
#if canImport(Firebase)
//    var  passioFirebaseAnalytics = PassioFirebaseAnalytics()
    // var  passioAnalytics: PassioScanningAnalytics?
#endif
    let passioSDK = PassioNutritionAI.shared
    var volumeDetectionMode = VolumeDetectionMode.none // auto// VolumeDetectionMode.auto
    var videoLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            backgroundImage?.fadeOut(seconds: 0.3)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundImage?.alpha = 1
//        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated),
//                                               name: UIDevice.orientationDidChangeNotification,
//                                               object: nil)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized { // already authorized
            setupVideoLayer()
            startDetection()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // access to video granted
                    DispatchQueue.main.async {
                        self.setupVideoLayer()
                        self.startDetection()
                    }
                } else {
                    print("The user didn't grant access to use camera")
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundImage.fadeIn(seconds: 0.2)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
//        stopDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
        passioSDK.removeVideoLayer()
    }

    func startDetection() {
#if canImport(Firebase)
        // passioAnalytics = PassioScanningAnalytics()
        #endif
    }

//    func stopDetection() {
//        // passioAnalytics?.uploadEndOfSanningSession()
//    }

    func setupVideoLayer() {
        guard videoLayer == nil else { return }
        print("setupVideoLayer volumeDetectionMode  == \(volumeDetectionMode)" )
        if let vLayer = passioSDK.getPreviewLayerWithGravity(volumeDetectionMode: volumeDetectionMode,
                                                             videoGravity: .resizeAspectFill) {

            videoLayer = vLayer
            let bgFrame = view.bounds
            var offset  = navigationController?.navigationBar.frame.maxY  ?? 0

            let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            offset += statusBarHeight

            let newFrame = CGRect(x: bgFrame.origin.x,
                                  y: bgFrame.origin.y + offset,
                                  width: bgFrame.width,
                                  height: bgFrame.height - offset)
            print("newFrame = \(newFrame) ")
            vLayer.frame = newFrame
           view.layer.insertSublayer(vLayer, at: 0)

        }
    }

}

extension RotationViewController { // extension to support videoLayer rotations.

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        //videoLayer?.frame = view.bounds
//    }
//
//    @objc func deviceRotated() {
//        if let connection = videoLayer?.connection,
//            connection.isVideoOrientationSupported == true {
//            connection.videoOrientation = getDeviceOrientation(currentOrientations: connection.videoOrientation)
//        }
//        videoLayer?.frame = view.bounds
//    }
//
//    func getDeviceOrientation(currentOrientations: AVCaptureVideoOrientation) -> AVCaptureVideoOrientation {
//        let orientation: AVCaptureVideoOrientation
//        switch UIDevice.current.orientation {
//        case .portrait:
//            orientation = .portrait
//        case .landscapeRight:
//            orientation = .landscapeLeft
//        case .landscapeLeft:
//            orientation = .landscapeRight
//        case .portraitUpsideDown:
//            if UIDevice.current.userInterfaceIdiom == .phone { // iPhone X doesn't support upsidedown
//                orientation = currentOrientations
//            } else {
//                orientation = .portraitUpsideDown
//            }
//        default:
//            orientation = .portrait
//        }
//        return orientation
//    }
//
//    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }

}
