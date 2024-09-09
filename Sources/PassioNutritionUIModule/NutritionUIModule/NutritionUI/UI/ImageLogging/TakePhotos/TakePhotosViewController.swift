//
//  TakePhotosViewController.swift
//
//
//  Created by Nikunj Prajapati on 11/06/24.
//

import UIKit
import AVFoundation
import Combine
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol UsePhotosDelegate: AnyObject {
    func onSelecting(images: [UIImage])
}

class TakePhotosViewController: InstantiableViewController, ImageLoggingService {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scanFrameImageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!

    private var captureSession: AVCaptureSession!
    private var backCamera: AVCaptureDevice?
    private var backInput: AVCaptureInput!
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    private let photoOutput = AVCapturePhotoOutput()
    private var cancellables = Set<AnyCancellable>()
    private var resultsLoggingView: ResultsLoggingView?
    private var selectedCellIndexPath: IndexPath?

    private var capturedImages: [UIImage] = []
    private var thumbnailImages: [UIImage] = [] {
        didSet {
            nextButton.enableDisableButton(with: .transitionCrossDissolve,
                                           duration: 0.17,
                                           isEnabled: thumbnailImages.count == 0 ? false : true)
            captureButton.enableDisableButton(with: .transitionCrossDissolve,
                                              duration: 0.17,
                                              isEnabled: thumbnailImages.count >= 7 ? false : true)
            imageCollectionView.reloadWithAnimations(withDuration: 0.21)
        }
    }

    var isStandAlone = true
    weak var delegate: UsePhotosDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
        checkPermissions()
        configureCollectionView()
        nextButton.enableDisableButton(with: .transitionCrossDissolve,
                                       duration: 0.17,
                                       isEnabled: thumbnailImages.count == 0 ? false : true)
        activityIndicatorView.color = .primaryColor
        nextButton.backgroundColor = .primaryColor
        cancelButton.applyBorder(width: 2, color: .primaryColor)
        cancelButton.setTitleColor(.primaryColor, for: .normal)
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
        if isStandAlone {
            fetchFoodData()
        } else {
            navigationController?.popViewController(animated: true) { [weak self] in
                guard let self else { return }
                delegate?.onSelecting(images: capturedImages)
            }
        }
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
                    self?.activityView.isHidden = true
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
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                showAlertWith(titleKey: "Back camera not found", view: self) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }

        // Create AVCaptureDeviceInput object from AVCaptureDevice
        guard let backCamera, let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
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

// MARK: - Helper
extension TakePhotosViewController {

    private func configureCollectionView() {
        imageCollectionView.register(nibName: ThumbnailImageCollectionCell.className)
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
    }

    private func onDeleteImage(index: Int) {
        guard thumbnailImages.indices.contains(index) else { return }
        thumbnailImages.remove(at: index)
    }

    private func fetchFoodData() {

        activityView.isHidden = false
        activityIndicatorView.startAnimating()
        messageLabel.text = "Generating results..."

        fetchFoodData(for: capturedImages) { [weak self] recognitionModel in
            guard let self else { return }
            activityView.isHidden = true
            if recognitionModel.count == 0 {
                showCustomAlert(title: CustomAlert.AlertTitle(titleText: "The system is unable to recognize images.",
                                                              rightButtonTitle: "Retake",
                                                              leftButtonTitle: "Cancel"),
                                font: CustomAlert.AlertFont(titleFont: .inter(type: .medium, size: 18),
                                                            rightButtonFont: .inter(type: .medium, size: 16),
                                                            leftButtonFont: .inter(type: .medium, size: 16)),
                                delegate: self)
            } else {
                loadResultLoggingView(recognitionData: recognitionModel)
            }
        }
    }

    private func loadResultLoggingView(recognitionData: [PassioSpeechRecognitionModel]) {

        DispatchQueue.main.async { [self] in
            resultsLoggingView = ResultsLoggingView.fromNib(bundle: .module)
            if let resultsLoggingView {
                resultsLoggingView.resultLoggingDelegate = self
                resultsLoggingView.showCancelButton = true
                resultsLoggingView.recognitionData = recognitionData
                view.addSubview(resultsLoggingView)
                resultsLoggingView.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraints(to: resultsLoggingView, attribute: .leading, constant: 0)
                view.addConstraints(to: resultsLoggingView, attribute: .trailing, constant: 0)
                view.addConstraints(to: resultsLoggingView, attribute: .bottom, constant: 0)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
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
        cell.onDelete = { [weak self] index in
            self?.onDeleteImage(index: index)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        select(item: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = view.frame.width/2 - (80/2)
        return UIEdgeInsets(
            top: 0,
            left: inset,
            bottom: 0,
            right: inset
        )
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToCell()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCell()
    }

    // MARK: Cell Helper
    private func select(item: Int, in section: Int = 0, animated: Bool = true) {

        guard item < thumbnailImages.count else { return }

        cleanupSelection()

        let indexPath = IndexPath(item: item, section: section)
        selectedCellIndexPath = indexPath

        let cell = imageCollectionView.cellForItem(at: indexPath) as? ThumbnailImageCollectionCell
        cell?.configure(with: thumbnailImages[indexPath.item], index: indexPath.item, isHidden: false)

        imageCollectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
    }

    private func cleanupSelection() {
        guard let indexPath = selectedCellIndexPath else { return }
        let cell = imageCollectionView.cellForItem(at: indexPath) as? ThumbnailImageCollectionCell
        cell?.configure(with: thumbnailImages[indexPath.item], index: indexPath.item)
        selectedCellIndexPath = nil
    }

    private func scrollToCell() {

        var indexPath = IndexPath()
        var visibleCells = imageCollectionView.visibleCells

        // Gets visible cells
        visibleCells = visibleCells.filter { cell -> Bool in
            let cellRect = imageCollectionView.convert(cell.frame, to: imageCollectionView.superview)
            // Calculate if at least 50% of the cell is in the boundaries we created
            let viewMidX = view.frame.midX
            let cellMidX = cellRect.midX
            let topBoundary = viewMidX + cellRect.width/2
            let bottomBoundary = viewMidX - cellRect.width/2
            // A print state representating what the return is calculating
            // print("topboundary: \(topBoundary) > cellMidX: \(cellMidX) > Bottom Boundary: \(bottomBoundary)")
            return topBoundary > cellMidX  && cellMidX > bottomBoundary
        }

        if visibleCells.count > 0 {
            // Appends visible cell index to `cellIndexPath`
            visibleCells.forEach({
                if let selectedIndexPath = imageCollectionView.indexPath(for: $0) {
                    indexPath = selectedIndexPath
                }
            })
            let item = indexPath.item
            // Disables animation on the first and last cell
            if item == 0 || item == thumbnailImages.count - 1 {
                select(item: item, animated: false)
                return
            }
            select(item: item)
        }
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

        if thumbnailImages.count >= 7 { return }
        if let previewImage {
            thumbnailImages.insert(previewImage, at: 0)
        }
        if let capturedImage = mainImage {
            let fixedImg = capturedImage.fixOrientation()
            capturedImages.append(fixedImg)
        }
    }
}

// MARK: - ResultLogging Delegate
extension TakePhotosViewController: ResultsLoggingDelegate {

    func onTryAgainTapped() {
        capturedImages.removeAll()
        thumbnailImages.removeAll()
        resultsLoggingView?.removeFromSuperview()
        resultsLoggingView = nil
    }

    func onLogSelectedTapped() {
        NutritionUICoordinator.navigateToDairyAfterAction(navigationController: navigationController)
    }

    func onSearchManuallyTapped() {}
}

// MARK: - ResultLogging Delegate
extension TakePhotosViewController: CustomAlertDelegate {

    func onRightButtonTapped(textValue: String?) {
        capturedImages.removeAll()
        thumbnailImages.removeAll()
    }

    func onleftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
