//
//  SelectPhotosViewController.swift
//  
//
//  Created by Nikunj Prajapati on 11/06/24.
//

import UIKit
import PhotosUI

class SelectPhotosViewController: InstantiableViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorStackView: UIStackView!
    @IBOutlet weak var selectedImageCollectionView: UICollectionView!

    private var selectedImages: [UIImage] = []

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
        picker.delegate = self
        present(picker, animated: true)
    }

    private func fetchFoodData() {

        var recognitionData: [PassioSpeechRecognitionModel] = []
        let dispatchGroup = DispatchGroup()

        selectedImages.forEach { image in

            dispatchGroup.enter()

            PassioNutritionAI.shared.recognizeImageRemote(image: image) { [weak self] (passioAdvisorFoodInfo) in
                guard let self else { return }
                passioAdvisorFoodInfo.forEach {
                    let model = PassioSpeechRecognitionModel(action: .none,
                                                             meal: PassioMealTime.currentMealTime(),
                                                             date: nil,
                                                             extractedIngridient: $0)
                    recognitionData.append(model)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) { [self] in
            activityIndicatorView.stopAnimating()
            activityIndicatorStackView.isHidden = true
            loadResultLoggingView(recognitionData: recognitionData)
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

        dispatchGroup.notify(queue: .main) { [weak self] in

            guard let self else { return }

            activityIndicatorStackView.isHidden = false
            activityIndicatorView.startAnimating()
            selectedImageCollectionView.reloadData()

            DispatchQueue.global(qos: .userInteractive).async {
                self.fetchFoodData()
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
        navigationController?.popViewController(animated: true) { [weak self] in
            self?.showMessage(msg: "Log Added", y: 80)
        }
    }

    func onSearchManuallyTapped() { }
}
