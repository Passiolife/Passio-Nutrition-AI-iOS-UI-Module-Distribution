//
//  DetectedFoodResultView.swift
//  BaseApp
//
//  Created by Harsh on 21/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//
import UIKit
import AVFoundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

internal enum DetectedFoodResultType {
    case addIngredient
    case addLog
}


protocol DetectedFoodResultViewDelegate: NSObjectProtocol {
    func didTapOnAddManual()
    func didTapOnAddIngredient(dataset: (any FoodRecognitionDataSet)?)
    func didTapOnEdit(dataset: (any FoodRecognitionDataSet)?)
    func didTapOnLog(dataset: (any FoodRecognitionDataSet)?)
    func didViewExpanded(isExpanded: Bool)
    func didScannedWrongBarcode()
    func didTaponAlternative(dataset: (any FoodRecognitionDataSet)?)
    func didViewStartedDragging(isDragging: Bool)
}

class DetectedFoodResultView: CustomModalViewController {

    @IBOutlet weak var spinnerView     : SpinnerView!
    @IBOutlet weak var imageFoodIcon   : UIImageView!
    @IBOutlet weak var labelTrayInfo   : UILabel!
    @IBOutlet weak var viewFoodItemData: UIView!
    @IBOutlet weak var labelFoodName   : UILabel!
    @IBOutlet weak var labelFoodDetails: UILabel!
    @IBOutlet weak var tblViewAlternatives: UITableView!
    @IBOutlet weak var manualStackView : UIStackView!
    @IBOutlet weak var buttonEdit      : UIButton!
    @IBOutlet weak var buttonLog       : UIButton!
    @IBOutlet weak var buttonAddIngredient: UIButton!
    @IBOutlet weak var searchManually: UIButton!

    private let passioSDK = PassioNutritionAI.shared
    private let connector = NutritionUIModule.shared

    weak var delegate: DetectedFoodResultViewDelegate?
    var resultViewFor: DetectedFoodResultType = .addLog {
        didSet {
            updateUI()
        }
    }
    
    private var currentDataSet: (any FoodRecognitionDataSet)? = nil {
        didSet {
            updateUI()
        }
    }

    override var isExpanded: Bool {
        didSet {
            delegate?.didViewExpanded(isExpanded: isExpanded)
        }
    }

    override var isDraggingStarted: Bool {
        didSet {
            delegate?.didViewStartedDragging(isDragging: isDraggingStarted)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonLog.backgroundColor = .primaryColor
        buttonEdit.setTitleColor(.primaryColor, for: .normal)
        let str = "Not what you’re looking for? Search Manually".toMutableAttributedString
        str.apply(attribute: [.foregroundColor: UIColor.primaryColor], subString: "Search Manually")
        searchManually.setAttributedTitle(str, for: .normal)
        buttonEdit.applyBorder(width: 2, color: .primaryColor)
        registerNib()
        addTapGesture()
        imageFoodIcon.roundMyCorner()
        setDragabble(isDraggable: false)
        self.buttonAddIngredient.isHidden = true
        updateUI()
    }

    private func registerNib() {
        tblViewAlternatives.register(nibName: "FoodAlternativesCell")
    }

    private func setDragabble(isDraggable: Bool) {

        if !PassioUserDefaults.bool(for: PassioUserDefaults.Key.dragTrayForFirstTime) && isDraggable {
            PassioUserDefaults.store(for: .dragTrayForFirstTime, value: true)
            labelTrayInfo.isHidden = false
        } else {
            labelTrayInfo.isHidden = true
        }

        viewDragMain.isHidden = !isDraggable
        shouldShowMiniOnly = !isDraggable
    }

    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnFoodItemDataView))
        viewFoodItemData.addGestureRecognizer(tapGesture)
    }

    func updateDataSet(newDataSet: (any FoodRecognitionDataSet)?) {
        guard newDataSet != nil else {
            currentDataSet = nil
            return
        }
        if let newDataSet = newDataSet as? BarcodeDataSet {
            if (currentDataSet as? BarcodeDataSet) == newDataSet { return }
            currentDataSet = newDataSet
            return
        } else if let newDataSet = newDataSet as? PackageFoodDataSet {
            if (currentDataSet as? PackageFoodDataSet) == newDataSet { return }
            currentDataSet = newDataSet
            return
        } else if let newDataSet = newDataSet as? VisualFoodDataSet {
            if (currentDataSet as? VisualFoodDataSet) == newDataSet { return }
            currentDataSet = newDataSet
            return
        }
    }

    private func updateUI() {
        if let barcodeDataSet = currentDataSet as? BarcodeDataSet {
            setupBarcodeDataSet(dataset: barcodeDataSet)
        } else if let packageFoodDataSet = currentDataSet as? PackageFoodDataSet {
            setupPackageFood(dataset: packageFoodDataSet)
        } else if let visualFoodDataSet = currentDataSet as? VisualFoodDataSet {
            setupVisualDataSet(dataset: visualFoodDataSet)
        } else {
            showLoadingView()
        }
    }

    private func showLoadingView() {
        spinnerView.stop()
        spinnerView.spin(color: .primaryColor, lineWidth: 5)
        labelFoodName.text = "Scanning..."
        labelFoodDetails.text = "Place your food within the frame."
        labelFoodDetails.isHidden = false
        buttonLog.isHidden = true
        buttonEdit.isHidden = true
        buttonAddIngredient.isHidden = true
        setDragabble(isDraggable: false)
        manualStackView.isHidden = true
        imageFoodIcon.isHidden = true
    }

    private func setupNoLoderView() {
        spinnerView.stop()
        buttonLog.isHidden = false
        buttonEdit.isHidden = false
        imageFoodIcon.isHidden = false
        labelFoodDetails.isHidden = true
        manualStackView.isHidden = false
        
        if resultViewFor == .addIngredient {
            self.buttonAddIngredient.isHidden = false
            self.buttonLog.isHidden = true
        }
        else {
            self.buttonAddIngredient.isHidden = true
            self.buttonLog.isHidden = false
        }
    }

    private func setupBarcodeDataSet(dataset: BarcodeDataSet) {
        dataset.getFoodItem(completion: { [weak self] (passioFoodItem) in
            guard let self else { return }
            if let foodItem = passioFoodItem {
                showFoodData(name: foodItem.name,
                             imageID: foodItem.iconId,
                             entityType: .barcode)
            } else if let barcodeFoodRecord = dataset.foodRecord { // Fetch from local if available
                showFoodData(name: barcodeFoodRecord.name,
                             imageID: barcodeFoodRecord.iconId,
                             entityType: .barcode)
            } else {
                delegate?.didScannedWrongBarcode()
            }
        })
    }

    private func showFoodData(name: String, imageID: String, entityType: PassioIDEntityType = .item) {
        DispatchQueue.main.async {
            self.setupNoLoderView()
            self.setupNameAndImage(name: name, passioID: imageID, entityType: entityType)
            self.setDragabble(isDraggable: false)
        }
    }

    private func setupPackageFood(dataset: PackageFoodDataSet) {
        dataset.getFoodItem(completion: { [weak self] (passioFoodItem) in
            guard let self else { return }
            if let foodItem = passioFoodItem {
                DispatchQueue.main.async {
                    self.setupNoLoderView()
                    self.setupNameAndImage(name: foodItem.name, 
                                           passioID: foodItem.iconId,
                                           entityType: .packagedFoodCode)
                    self.setDragabble(isDraggable: false)
                }
            }
        })
    }

    private func setupVisualDataSet(dataset: VisualFoodDataSet) {
        guard let candidate = dataset.candidate else { return }
        self.setupNoLoderView()
        self.setupNameAndImage(name: candidate.name, passioID: candidate.passioID)
        self.setDragabble(isDraggable: dataset.allAlternatives.count > 0)
        let actual = dataset.allAlternatives.count * 64 - 8
        self.maximumContainerHeight = CGFloat(min(actual, 200))
        self.tblViewAlternatives.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.tblViewAlternatives.reloadData()
    }

    private func setupNameAndImage(name: String,
                                   passioID: String,
                                   entityType: PassioIDEntityType = .item) {
        labelFoodName.text = name.capitalized
        imageFoodIcon.setFoodImage(id: passioID,
                                   passioID: passioID,
                                   entityType: entityType,
                                   connector: connector) { image in
            DispatchQueue.main.async {
                self.imageFoodIcon.image = image
            }
        }
    }

    // MARK: Tap Gesture for FoodItemDataView
    @objc func didTapOnFoodItemDataView() {
        delegate?.didTapOnEdit(dataset: currentDataSet)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DetectedFoodResultView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.currentDataSet as? VisualFoodDataSet)?.allAlternatives.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueCell(cellClass: FoodAlternativesCell.self, forIndexPath: indexPath)

        if indexPath.row < ((self.currentDataSet as? VisualFoodDataSet)?.allAlternatives ?? []).count {

            let alternative = ((self.currentDataSet as? VisualFoodDataSet)?.allAlternatives ?? [])[indexPath.row]
            cell.setupNameAndImage(name: alternative.name, passioID: alternative.passioID)

            cell.onQuickAddAlternative = { [weak self] in
                guard let self else { return }
                let alternativeDataset = VisualFoodDataSet(candidate: alternative)
                self.delegate?.didTaponAlternative(dataset: alternativeDataset)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let alternative = ((self.currentDataSet as? VisualFoodDataSet)?.allAlternatives ?? [])[indexPath.row]
        let alternativeDataset = VisualFoodDataSet(candidate: alternative)

        self.delegate?.didTapOnEdit(dataset: alternativeDataset)

        //Testing personalisation enginge
        if let currentVisualDataSet = (self.currentDataSet as? VisualFoodDataSet),
           let _ = currentVisualDataSet.id {
            let _ = currentVisualDataSet.allAlternatives[indexPath.row].passioID

            if let visualCandidate = (self.currentDataSet as? VisualFoodDataSet)?.candidate {
                let alternative = currentVisualDataSet.allAlternatives[indexPath.row]
                PassioNutritionAI.shared.addToPersonalization(visualCadidate: visualCandidate, alternative: alternative)
            }
        }
    }
}

//MARK: - Button actions
extension DetectedFoodResultView {

    @IBAction func buttonSearchManuallyTapped(_ sender: UIButton) {
        delegate?.didTapOnAddManual()
    }

    @IBAction func buttonEditTapped(_ sender: UIButton) {
        delegate?.didTapOnEdit(dataset: currentDataSet)
    }

    @IBAction func buttonLogTapped(_ sender: UIButton) {
        delegate?.didTapOnLog(dataset: currentDataSet)
    }
    
    @IBAction func buttonAddIngredientTapped(_ sender: UIButton) {
        delegate?.didTapOnAddIngredient(dataset: currentDataSet)
    }
}
