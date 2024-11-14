//
//  SelectPhotosViewController.swift
//  
//
//  Created by Nikunj Prajapati on 11/06/24.
//

import UIKit
import PhotosUI
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class SelectPhotosViewController: InstantiableViewController, ImageLoggingService {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var generatingResultsLabel: UILabel!

    private var selectedImages: [UIImage] = []

    var isStandAlone = true
    weak var delegate: UsePhotosDelegate?
    var goToSearch: (() -> Void)?
    private var resultsLoggingView: ResultsLoggingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showPhotos()
        }
        configureCollectionView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func basicSetup() {
        //navigationController?.setNavigationBarHidden(true, animated: true)
        setupBackButton()
        generatingResultsLabel.font = UIFont.inter(type: .medium, size: 15)
    }

    // MARK: - Configure CollectionView
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(nibName: SelectedImageCell.className)
    }

    // MARK: - Helper
    private func showPhotos() {

        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 7
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.isModalInPresentation = true
        picker.delegate = self
        present(picker, animated: true)
    }

    // Fetch FoodData for selected images
    private func fetchFoodData() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.fetchFoodData(for: self.selectedImages) { [weak self] recognitionModel in
                guard let self else { return }
                loadingView.isHidden = true
                loadResultLoggingView(recognitionData: recognitionModel)
            }
        }
    }

    private func loadResultLoggingView(recognitionData: [PassioSpeechRecognitionModel]) {

        DispatchQueue.main.async { [self] in
            resultsLoggingView = ResultsLoggingView.fromNib(bundle: .module)
            let image = UIImage.imageFromBundle(named: "useImage")
            resultsLoggingView.tryAgainButton.setImage(image, for: .normal)
            resultsLoggingView.tryAgainButton.setTitle("Search Again", for: .normal)
            resultsLoggingView.resultLoggingDelegate = self
            resultsLoggingView.recognitionData = recognitionData
            view.addSubview(resultsLoggingView)
            resultsLoggingView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(to: resultsLoggingView, attribute: .leading, constant: 0)
            view.addConstraints(to: resultsLoggingView, attribute: .trailing, constant: 0)
            view.addConstraints(to: resultsLoggingView, attribute: .bottom, constant: 0)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension SelectPhotosViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(cellClass: SelectedImageCell.self, forIndexPath: indexPath)
        cell.configureCell(with: selectedImages[indexPath.item])
        return cell
    }
}

extension SelectPhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = (selectedImages.count > 3) ? 3 : selectedImages.count
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(itemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(itemsPerRow))
        return CGSize(width: size, height: size)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension SelectPhotosViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            if results.count == 0 {
                navigationController?.popViewController(animated: true)
            }
        }
        if results.count == 0 {
            navigationController?.popViewController(animated: true)
            return
        }

        let dispatchGroup = DispatchGroup()

        results.forEach { phPickerResult in
            dispatchGroup.enter()
            let itemProvider = phPickerResult.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    guard let self else { return }
                    if let image = image as? UIImage {
                        selectedImages.append(image)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                }
            } else {
                dispatchGroup.leave()
            }
        }

        // Show selected images
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if isStandAlone {
                loadingView.isHidden = false
                collectionView.reloadData()
                fetchFoodData()
            } else {
                navigationController?.popViewController(animated: true) { [weak self] in
                    guard let self else { return }
                    delegate?.onSelecting(images: selectedImages)
                }
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension SelectPhotosViewController: ResultsLoggingDelegate {

    func onTryAgainTapped() {
        //navigationController?.popViewController(animated: true)
        resultsLoggingView?.removeFromSuperview()
        selectedImages.removeAll()
        collectionView.reloadData()
        showPhotos()
    }

    func onLogSelectedTapped() {
        NutritionUICoordinator.navigateToDairyAfterAction(navigationController: navigationController)
    }

    func onSearchManuallyTapped() {
        navigationController?.popViewController(animated: true) { [weak self] in
            self?.goToSearch?()
        }
    }
}
