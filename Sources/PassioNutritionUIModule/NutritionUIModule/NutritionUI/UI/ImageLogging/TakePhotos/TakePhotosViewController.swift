//
//  TakePhotosViewController.swift
//
//
//  Created by Nikunj Prajapati on 11/06/24.
//

import UIKit
import AVFoundation
import Combine

class TakePhotosViewController: InstantiableViewController {

    @IBOutlet weak var scanFrameImageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var activityIndicatorStackView: UIStackView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    private var captureSession: AVCaptureSession!
    private var backCamera: AVCaptureDevice!
    private var backInput: AVCaptureInput!
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    private let photoOutput = AVCapturePhotoOutput()
    private var cancellables = Set<AnyCancellable>()

    private var capturedImages: [UIImage] = [] {
        didSet {
            captureButton.isEnabled = capturedImages.count >= 7 ? false : true
            captureButton.alpha = capturedImages.count >= 7 ? 0.8 : 1
        }
    }
    var thumbnailImages: [UIImage] = [] {
        didSet {
           reloadAndScroll(at: thumbnailImages.count - 1)
        }
    }
    private var resultLoggingView: ResultsLoggingView?

    let cellId = "ThumbnailImageCollectionCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
        checkPermissions()
        imageCollectionView.register(nibName: cellId)
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: @IBActions
    @IBAction func onCaptureImage(_ sender: UIButton) {
        photoOutput.capturePhoto(with: configurePhotoSettings(), delegate: self)
    }

    @IBAction func onNext(_ sender: UIButton) {

    }

    @IBAction func onCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Camera Configuration
extension TakePhotosViewController {

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupAndStartCaptureSession()
        case .denied:
            showAlertWith(titleKey: "Allow camera permission in settings to Identify foods in Image", view: self)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] (authorized) in
                guard let self else { return }
                if !authorized {
                    showAlertWith(titleKey: "Allow camera permission in settings to Identify foods in Image", view: self)
                } else {
                    setupAndStartCaptureSession()
                }
            }
        case .restricted:
            showAlertWith(titleKey: "Allow camera permission in settings to Identify foods in Image", view: self)
        @unknown default:
            fatalError()
        }
    }

    private func setupAndStartCaptureSession() {

        DispatchQueue.global(qos: .userInteractive).async { [self] in
            // Session Configuration
            captureSession = AVCaptureSession()
            captureSession.beginConfiguration()
            obsserveCaptureSession()
            // Set Photo Preset
            if captureSession.canSetSessionPreset(.hd1920x1080) {
                captureSession.sessionPreset = .hd1920x1080
            }
            // Set Camera Inputs and Outputs
            setCameraInputs()
            setOutputs()
            // Setup preview layer
            DispatchQueue.main.async {
                self.setupPreviewLayer()
            }
            // Commit Configuration and start running session
            captureSession.commitConfiguration()
            captureSession.startRunning()
        }
    }

    private func obsserveCaptureSession() {
        captureSession.publisher(for: \.isRunning)
            .filter { $0 } // Only proceed when isRunning is true
            .sink { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self?.activityIndicatorStackView.isHidden = true
                }
            }
            .store(in: &cancellables)
    }

    private func setCameraInputs() {
        // Get best available back camera for capturing photos
        if let device = AVCaptureDevice.default(CapturingDeviceType.getCapturingDeviceForPhotos().device,
                                                for: .video,
                                                position: .back) {
            backCamera = device
        } else {
            //handle this appropriately for production purposes
            showAlertWith(titleKey: "Back camera not found", view: self)
        }
        // Create AVCaptureDeviceInput object from AVCaptureDevice
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            print("could not create input device from back camera")
            return
        }
        backInput = bInput

        if !captureSession.canAddInput(backInput) {
            print("could not add back camera input to capture session")
        }
        // Connect back camera input to session
        captureSession.addInput(backInput)
    }

    private func setOutputs() {
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        // photoOutput.connections.first?.videoOrientation = .portrait
    }

    private func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer.frame = view.bounds
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }

    private func configurePhotoSettings() -> AVCapturePhotoSettings {

        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType,
                kCVPixelBufferWidthKey as String: 200,
                kCVPixelBufferHeightKey as String: 200
            ]
            photoSettings.previewPhotoFormat = previewFormat
        }
        if let photoOutputConnection = photoOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = .portrait
        }
        photoSettings.flashMode = .auto
        return photoSettings
    }
}

// MARK: - Images Carousel CollectionView Configuration
extension TakePhotosViewController: UICollectionViewDataSource,
                                    UICollectionViewDelegate,
                                    UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        thumbnailImages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueCell(cellClass: ThumbnailImageCollectionCell.self,
                                              forIndexPath: indexPath)
        cell.configure(with: thumbnailImages[indexPath.item], index: indexPath.item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
}

// MARK: - Carousel CollectionView Configuration
extension TakePhotosViewController {

//    func configure(for collectionView: InfiniteCollectionView) {
//
//        collectionView.register(UINib(nibName: cellId, bundle: .module),
//                                forCellWithReuseIdentifier: cellId)
//        collectionView.infiniteDataSource = self
//        collectionView.infiniteDelegate = self
//        collectionView.delegate = self
//        collectionView.isFinishedInitializing = { [weak self] in
//            guard let self else { return }
//            if thumbnailImages.count > 0 {
//                thumbnailImages.removeAll()
//            }
//        }
//        collectionView.reloadData()
//    }

    func reloadAndScroll(at index: Int) {

        imageCollectionView.reloadData()
//        let indexPath = IndexPath(item: index, section: 0)
//        if index < thumbnailImages.count {
////            if var rect = foodImageCollectionView.layoutAttributesForItem(at: IndexPath(item: index,
////                                                                                        section: 0))?.frame {
////                rect = CGRect(x: rect.minX + 80, y: rect.minY, width: rect.width, height: rect.height)
////                foodImageCollectionView.scrollRectToVisible(rect, animated: true)
////            }
//            foodImageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
    }
}

// MARK: - Carousel CollectionView DataSource & Delegate
//extension TakePhotosViewController: InfiniteCollectionViewDataSource, InfiniteCollectionViewDelegate {
//
//    func numberOfItems(_ collectionView: UICollectionView) -> Int {
//        if collectionView == foodImageCollectionView {
//            return thumbnailImages.count
//        }
//        return 0
//    }
//
//    func cellForItemAtIndexPath(_ collectionView: UICollectionView,
//                                dequeueIndexPath: IndexPath,
//                                usableIndexPath: IndexPath) -> UICollectionViewCell {
//
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId,
//                                                            for: dequeueIndexPath) as? ThumbnailImageCollectionCell else {
//            return UICollectionViewCell()
//        }
//
////        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
////        cell.distanceFromCenter = visibleRect.midX - cell.frame.midX
//
//        if collectionView == foodImageCollectionView,
//           let item = thumbnailImages[safe: usableIndexPath.item] {
//            cell.configure(with: item, index: usableIndexPath.item)
//        }
//        return cell
//    }
//
//    func navigationTapped(_ collectionView: UICollectionView, offset: Int) {
//
//        if collectionView == foodImageCollectionView,
//           let primaryCollectionView = collectionView as? InfiniteCollectionView {
//
//            if (1 ... 4).contains(primaryCollectionView.numberOfItems(inSection: 0)) {
//
//                primaryCollectionView.fewItemsIndex = offset
//                primarySelectedIndex = offset
//                updateImage(in: primaryCollectionView, fewItemIndex: offset)
//                updatedPrimaryItem(index: offset)
//
//            } else {
//                if offset == 0 {
//                    updatedPrimaryItem(index: nil)
//                } else {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
//                        updateImage(in: primaryCollectionView)
//                    }
//                }
//            }
//        }
//    }
//}

// MARK: - ScrollView Delegate methods
//extension TakePhotosViewController: UICollectionViewDelegate {
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let collectionView = scrollView as? InfiniteCollectionView else {
//            return
//        }
//        if scrollView.isDragging {
//            handleHapticFeedback(for: collectionView)
//        }
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        scrollViewStopScrolling(scrollView)
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            scrollViewStopScrolling(scrollView)
//        }
//    }
//
//    private func scrollViewStopScrolling(_ scrollView: UIScrollView) {
//        guard let collectionView = scrollView as? InfiniteCollectionView else {
//            return
//        }
//        let useZeroIndex = (0...4).contains(thumbnailImages.count) ? true : false
//        updateImage(in: collectionView, shouldUseZeroIndex: useZeroIndex)
//    }
//}

// MARK: - Handle Haptic Feedback
extension TakePhotosViewController {

//    func handleHapticFeedback(for collectionView: InfiniteCollectionView) {
//        let index = collectionView.getCenterIndex()
//        if index == 0,
//           !hapticFeedbackOccured {
//            hapticFeedbackOccured = true
//            hapticFeedback()
//        } else if index != 0 {
//            hapticFeedbackOccured = false
//        }
//    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension TakePhotosViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: (any Error)?) {

        // Get the main image
        guard let photoData = photo.fileDataRepresentation() else {
            return
        }
        let mainImage = UIImage(data: photoData)

        // Get the preview
        // First try getting preview photo orientation from metadata
        var previewPhotoOrientation: CGImagePropertyOrientation?
        if let orientationNum = photo.metadata[kCGImagePropertyOrientation as String] as? NSNumber {
            previewPhotoOrientation = CGImagePropertyOrientation(rawValue: orientationNum.uint32Value)
        }

        // Then try getting the photo preview
        var previewImage: UIImage?
        if let previewPixelBuffer = photo.previewPixelBuffer {
            var previewCiImage = CIImage(cvPixelBuffer: previewPixelBuffer)
            // If we managed to get the oreintation, update the image
            if let previewPhotoOrientation = previewPhotoOrientation {
                previewCiImage = previewCiImage.oriented(previewPhotoOrientation)
            }
            if let previewCgImage = CIContext().createCGImage(previewCiImage, from: previewCiImage.extent) {
                previewImage = UIImage(cgImage: previewCgImage)
            }
        }

        if let previewImage {
            thumbnailImages.append(previewImage)
        }
        if let capturedImage = mainImage {
            let fixedImg = capturedImage.fixOrientation()
            capturedImages.append(fixedImg)
        }
    }
}
