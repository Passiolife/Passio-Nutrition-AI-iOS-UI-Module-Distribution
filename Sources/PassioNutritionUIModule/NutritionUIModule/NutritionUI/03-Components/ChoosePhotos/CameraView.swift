//
//  CameraView.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 21/05/25.
//

import UIKit
import AVFoundation

/**
 Use this when you want to capture single image
 This is a UIView
 */

protocol CameraViewDelegate: AnyObject {
    func didCaptureImage(image: UIImage?, error: Error?)
}

final class CameraView: UIView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!

    @IBOutlet private weak var controlsContainer: UIView!
    @IBOutlet private weak var captureButton: UIButton!
    
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureCompletion: ((UIImage?) -> Void)?
    private var isConfigured = false
    weak var delegate: CameraViewDelegate?

    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.module.loadNibNamed("CameraView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        basicSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = contentView.bounds
    }
    
    // MARK: - Public
    
    func startCamera(permissionGranted: ((Bool) -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                guard granted else {
                    permissionGranted?(false)
                    return
                }
                if !self.isConfigured {
                    self.setupSession()
                }
                self.loader.startAnimating()
                DispatchQueue.global(qos: .userInitiated).async {
                    self.session.startRunning()
                    DispatchQueue.main.async {
                        self.loader.stopAnimating()
                        self.controlsContainer.isHidden = false
                        permissionGranted?(true)
                    }
                }
            }
        }
    }
    
    func startRunning() {
        self.loader.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                self.controlsContainer.isHidden = false
            }
        }
    }
    
    func stopRunning() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.controlsContainer.isHidden = true
            }
        }
    }
    
    // MARK: - Private Setup
    
    private func setupSession() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input),
              session.canAddOutput(photoOutput) else {
            print("Failed to set up session")
            return
        }
        
        session.sessionPreset = .photo
        session.addInput(input)
        session.addOutput(photoOutput)
        session.commitConfiguration()
        
        configurePreview()
        isConfigured = true
    }
    
    private func configurePreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = contentView.bounds
        if let previewLayer = previewLayer {
            contentView.layer.insertSublayer(previewLayer, at: 0)
        }
    }
    
    private func basicSetup() {
        controlsContainer.isHidden = true
        captureButton.addTarget(self, action: #selector(captureTapped), for: .touchUpInside)
    }
    
    @objc private func captureTapped() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraView: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        if let error = error {
            print("Capture Image error: \(error)")
            DispatchQueue.main.async {
                self.delegate?.didCaptureImage(image: nil, error: error)
            }
            return
        }
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            DispatchQueue.main.async {
                self.delegate?.didCaptureImage(image: nil, error: nil)
            }
            return
        }
        DispatchQueue.main.async {
            self.delegate?.didCaptureImage(image: image, error: nil)
        }
    }
}
