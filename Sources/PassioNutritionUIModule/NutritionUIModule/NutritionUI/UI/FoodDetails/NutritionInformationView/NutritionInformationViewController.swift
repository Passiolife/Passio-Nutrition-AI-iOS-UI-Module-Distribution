//
//  NutritionInformationViewController.swift
//
//
//  Created by Nikunj Prajapati on 21/08/24.
//

import UIKit

struct FoodData {
    let name: String
    let barcode: String
    let icon: UIImage
    let nutritionInfo: [MicroNutirents]
}

struct NutritionInfo {
    let name: String
    let value: Double
    let unit: String
}

class NutritionInformationViewController: InstantiableViewController {

    @IBOutlet weak var pleaseNoteInfoView: UIView!
    @IBOutlet weak var foodInfoView: UIView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var barcodeValueLabel: UILabel!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nutritionInfoCollectionView: UICollectionView!

    var foodData: FoodData? {
        didSet {
            setFoodData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    private func configureUI() {

        title = "Nutrition Information"
        setupBackButton()

        nutritionInfoCollectionView.dataSource = self
        nutritionInfoCollectionView.delegate = self
        nutritionInfoCollectionView.register(nibName: NutritionInfoCollectionViewCell.className)
        nutritionInfoCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)

        foodInfoView.dropShadow(radius: 8,
                                offset: CGSize(width: 0, height: 1),
                                color: .black.withAlphaComponent(0.06),
                                shadowRadius: 2,
                                shadowOpacity: 1)
        pleaseNoteInfoView.dropShadow(radius: 8,
                                      offset: CGSize(width: 0, height: 1),
                                      color: .black.withAlphaComponent(0.06),
                                      shadowRadius: 2,
                                      shadowOpacity: 1)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        DispatchQueue.main.async { [self] in
            foodInfoView.layer.shadowPath = UIBezierPath(roundedRect: foodInfoView.bounds,
                                                         cornerRadius: 8).cgPath
            pleaseNoteInfoView.layer.shadowPath = UIBezierPath(roundedRect: pleaseNoteInfoView.bounds,
                                                               cornerRadius: 8).cgPath
        }
    }

    private func setFoodData() {
        if let foodData {
            foodNameLabel.text = foodData.name.capitalized
            if foodData.barcode != "" {
                barcodeValueLabel.text = "UPC: \(foodData.barcode)"
            } else {
                barcodeValueLabel.isHidden = true
            }
            foodImageView.image = foodData.icon
            nutritionInfoCollectionView.reloadData()
        }
    }

    @IBAction func onClose(_ sender: UIButton) {
        pleaseNoteInfoView.isHidden = true
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension NutritionInformationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        foodData?.nutritionInfo.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueCell(cellClass: NutritionInfoCollectionViewCell.self,
                                              forIndexPath: indexPath)
        if let nutritionInfo = foodData?.nutritionInfo {
            cell.configureNutritionInfoCell(with: nutritionInfo[indexPath.item])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (ScreenSize.width - 16) / 2, height: 140)
    }
}
