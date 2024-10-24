//
//  PlusMenuViewController.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 24/06/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

protocol PlusMenuDelegate: AnyObject {
    func onFoodScannerSelected()
    func onSearchSelected()
    func onFavouritesSelected()
    func onMyFoodsSelected()
    func onVoiceLoggingSelected()
    func onTakePhotosSelected()
    func onSelectPhotosSelected()
    func onNutritionAdvisorSelected()
}

extension PlusMenuDelegate {
    func onFoodScannerSelected() { }
    func onSearchSelected() { }
    func onFavouritesSelected() { }
    func onMyFoodsSelected() { }
    func onVoiceLoggingSelected() { }
    func onTakePhotosSelected() { }
    func onSelectPhotosSelected() { }
    func onNutritionAdvisorSelected() { }
}

final class PlusMenuViewController: InstantiableViewController {

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var tableVwHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    enum Rows: String {

        case favourite
        case search
        case scan
        case myFoods
        case voiceLogging
        case useImage
        case takePhotos
        case selectPhotos
        case nutritionAdvisor

        var image: UIImage? {
            switch self {
            case .favourite: UIImage.imageFromBundle(named: "favorites")
            case .search: UIImage.imageFromBundle(named: "search")
            case .scan: UIImage.imageFromBundle(named: "foodScanner")
            case .myFoods: UIImage.imageFromBundle(named: "myFoods")
            case .voiceLogging: UIImage.imageFromBundle(named: "voiceLogging")
            case .takePhotos: UIImage.imageFromBundle(named: "takePhotos")
            case .selectPhotos: UIImage.imageFromBundle(named: "selectPhotos")
            case .useImage: UIImage.imageFromBundle(named: "useImage")
            case .nutritionAdvisor: UIImage.imageFromBundle(named: "aiAdvisor")
            }
        }

        var title: String? {
            switch self {
            case .favourite: Localized.favorites
            case .search: Localized.textSearch
            case .scan: Localized.foodScan
            case .myFoods: "My Foods"
            case .voiceLogging: "Voice Logging"
            case .takePhotos: "Take Photos"
            case .selectPhotos: "Select Photos"
            case .useImage: "Use Image"
            case .nutritionAdvisor: "AI Advisor"
            }
        }
    }

    private let allRows: [Rows] = [.myFoods,
                                   .favourite,
                                   .voiceLogging,
                                   .nutritionAdvisor,
                                   .useImage,
                                   .search,
                                   .scan,
                                   .takePhotos,
                                   .selectPhotos]
    var menuData: [Rows] = [.myFoods,
                            .favourite,
                            .voiceLogging,
                            .nutritionAdvisor,
                            .useImage,
                            .search,
                            .scan,
                            .takePhotos,
                            .selectPhotos]
    var bottomCountedValue: CGFloat = 70.0

    weak var delegate: PlusMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        dismissButton.backgroundColor = .primaryColor
        menuTableView.isHidden = true
        menuTableView.clipsToBounds = true
        menuData = menuData.filter { $0 != .takePhotos && $0 != .selectPhotos }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            menuTableView.isHidden = false
            animate()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        bottomConstraint.constant = bottomCountedValue
        tableVwHeightConstraint.constant = CGFloat(66 * menuData.count)
        dismissButton.layoutIfNeeded()
        menuTableView.layoutIfNeeded()
    }

    func animate() {
        UIView.animate(withDuration: 0.1) {
            self.dismissButton.transform = CGAffineTransform(rotationAngle: .pi / 4 * 7)
        }
        let views = menuTableView.visibleCells.map { $0.contentView }.reversed()
        var delay = 0.0
        views.forEach { view in
            view.frame.origin.x = 200
            view.layoutSubviews()
            UIView.animate(withDuration: 0.1, delay: delay) {
                view.frame.origin.x = 0
                view.layoutSubviews()
            }
            delay += 0.053
        }
    }
}

// MARK: - Configure UI
extension PlusMenuViewController {

    private func configureUI() {
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.register(nibName: "PlusMenuCell")
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension PlusMenuViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(cellClass: PlusMenuCell.self, forIndexPath: indexPath)
        let menu = menuData[indexPath.row]
        cell.menuImageView.image = menu.image
        cell.menuImageView.tintColor = .primaryColor
        cell.menuNameLabel.text = menu.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = menuData[indexPath.row]
        if menu != .useImage {
            dismiss(animated: true)
        }
        menuData = allRows
        switch menu {
        case .favourite:
            delegate?.onFavouritesSelected()
        case .scan:
            delegate?.onFoodScannerSelected()
        case .search:
            delegate?.onSearchSelected()
        case .myFoods:
            delegate?.onMyFoodsSelected()
        case .voiceLogging:
            delegate?.onVoiceLoggingSelected()
        case .takePhotos:
            delegate?.onTakePhotosSelected()
        case .selectPhotos:
            delegate?.onSelectPhotosSelected()
        case .useImage:
            menuData = menuData.filter { $0 == .takePhotos || $0 == .selectPhotos }
            menuTableView.reloadWithAnimations(withDuration: 0.12)
        case .nutritionAdvisor:
            delegate?.onNutritionAdvisorSelected()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewWillLayoutSubviews()
    }
}

// MARK: - @IBAction
extension PlusMenuViewController {

    @IBAction func onCloseMenu(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
