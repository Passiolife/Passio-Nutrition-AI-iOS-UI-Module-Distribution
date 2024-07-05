//
//  SelectPhotosViewController.swift
//  
//
//  Created by Nikunj Prajapati on 11/06/24.
//

import UIKit
import PhotosUI
import PassioNutritionAISDK

class SelectPhotosViewController: InstantiableViewController, ImageLoggingService {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorStackView: UIStackView!
    @IBOutlet weak var selectedImageCollectionView: UICollectionView!

    private var selectedImages: [UIImage] = []

    var isStandAlone = true
    weak var delegate: UsePhotosDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showPhotos()
        }
        configureCollectionView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Configure CollectionView
    private func configureCollectionView() {
        selectedImageCollectionView.dataSource = self
        selectedImageCollectionView.delegate = self
        selectedImageCollectionView.collectionViewLayout = createCompositionalLayout()
        selectedImageCollectionView.register(nibName: "SelectedImageCell")
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {

        let compositionalLayout: UICollectionViewCompositionalLayout = {

            let fraction: CGFloat = 1/3

            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let inset: CGFloat = 4

            // After item declaration…
            item.contentInsets = NSDirectionalEdgeInsets(top: inset,
                                                         leading: inset,
                                                         bottom: inset,
                                                         trailing: inset)
            // Group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalWidth(fraction))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            // Section
            let section = NSCollectionLayoutSection(group: group)
            // After section delcaration…
            section.contentInsets = NSDirectionalEdgeInsets(top: inset,
                                                            leading: inset,
                                                            bottom: inset,
                                                            trailing: inset)
            return UICollectionViewCompositionalLayout(section: section)
        }()
        return compositionalLayout
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
                activityIndicatorView.stopAnimating()
                activityIndicatorStackView.isHidden = true

                if recognitionModel.count == 0 {
                    showCustomAlert(title: CustomAlert.AlertTitle(titleText: "The system is unable to recognize images.",
                                                                  rightButtonTitle: "Select Photos",
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
    }

    private func loadResultLoggingView(recognitionData: [PassioSpeechRecognitionModel]) {

        DispatchQueue.main.async { [self] in
            let resultsLoggingView = ResultsLoggingView.fromNib(bundle: .module)
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

// MARK: - PHPickerViewControllerDelegate
extension SelectPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        selectedImages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueCell(cellClass: SelectedImageCell.self, forIndexPath: indexPath)
        cell.configureCell(with: selectedImages[indexPath.item])
        return cell
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
                activityIndicatorStackView.isHidden = false
                activityIndicatorView.startAnimating()
                selectedImageCollectionView.reloadData()
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
        navigationController?.popViewController(animated: true)
    }

    func onLogSelectedTapped() {
        NutritionUICoordinator.navigateToDairyAfterAction(navigationController: navigationController)
    }

    func onSearchManuallyTapped() { }
}

// MARK: - PHPickerViewControllerDelegate
extension SelectPhotosViewController: CustomAlertDelegate {

    func onRightButtonTapped(textValue: String?) {
        selectedImages.removeAll()
        selectedImageCollectionView.reloadData()
        showPhotos()
    }

    func onleftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
