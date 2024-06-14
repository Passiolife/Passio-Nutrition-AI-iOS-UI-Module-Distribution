//
//  PlusMenuViewController.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 24/06/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

protocol PlusMenuDelegate: AnyObject {
    func onScanSelected()
    func onSearchSelected()
    func onFavouritesSelected()
    func onRecipesSelected()
    func onMyFoodsSelected()
    func onVoiceLoggingSelected()
    func takePhotosSelected()
    func selectPhotosSelected()
}

final class PlusMenuViewController: InstantiableViewController {

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var tableVwHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    enum Rows: String {

        case recipe
        case favourite
        case search
        case scan
        case myFoods
        case voiceLogging
        case useImage
        case takePhotos
        case selectPhotos

        var image: UIImage? {
            switch self {
            case .recipe: UIImage.imageFromBundle(named: "Recipes")
            case .favourite: UIImage.imageFromBundle(named: "Heart")
            case .search: UIImage.imageFromBundle(named: "Search")
            case .scan: UIImage.imageFromBundle(named: "Scan")
            case .myFoods: UIImage.imageFromBundle(named: "myFoods")
            case .voiceLogging: UIImage.imageFromBundle(named: "voiceLogging")
            case .takePhotos: UIImage.imageFromBundle(named: "takePhotos")
            case .selectPhotos: UIImage.imageFromBundle(named: "selectPhotos")
            case .useImage: UIImage.imageFromBundle(named: "useImage")
            }
        }

        var title: String? {
            switch self {
            case .recipe: Localized.recipes
            case .favourite: Localized.favorites
            case .search: Localized.textSearch
            case .scan: Localized.foodScan
            case .myFoods: "My Foods"
            case .voiceLogging: "Voice Logging"
            case .takePhotos: "Take Photos"
            case .selectPhotos: "Select Photos"
            case .useImage: "Use Image"
            }
        }
    }

    private var menuData: [Rows] = [.myFoods,
                                    .favourite,
                                    .voiceLogging,
                                    .useImage,
                                    .search,
                                    .scan,
                                    .takePhotos,
                                    .selectPhotos]
    private let allRows: [Rows] = [.myFoods,
                                   .favourite,
                                   .voiceLogging,
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
            delay += 0.08
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
        case .recipe:
            delegate?.onRecipesSelected()
        case .scan:
            delegate?.onScanSelected()
        case .search:
            delegate?.onSearchSelected()
        case .myFoods:
            delegate?.onMyFoodsSelected()
        case .voiceLogging:
            delegate?.onVoiceLoggingSelected()
        case .takePhotos:
            delegate?.takePhotosSelected()
        case .selectPhotos:
            delegate?.selectPhotosSelected()
        case .useImage:
            menuData = menuData.filter { $0 == .takePhotos || $0 == .selectPhotos }
            menuTableView.reloadWithAnimations(withDuration: 0.12)
        }
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        viewWillLayoutSubviews()
    }
}

// MARK: - @IBAction
extension PlusMenuViewController {

    @IBAction func onCloseMenu(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
