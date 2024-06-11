//
//  TakePhotosViewController.swift
//  
//
//  Created by nikunj Prajapati on 11/06/24.
//

import UIKit
import AVFoundation

class TakePhotosViewController: InstantiableViewController {
    
    @IBOutlet weak var scanFrameImageView: UIImageView!

    var captureSession : AVCaptureSession!
    var resultLoggingView: ResultsLoggingView?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: Configure UI
    private func configureUI() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupAndStartCaptureSession()
    }

    private func setupAndStartCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            captureSession = AVCaptureSession()
            captureSession.beginConfiguration()
            captureSession.commitConfiguration()
            captureSession.startRunning()
        }
    }

    // MARK: @IBActions
    @IBAction func onCaptureImage(_ sender: UIButton) {

    }

    @IBAction func onNext(_ sender: UIButton) {

    }

    @IBAction func onCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
