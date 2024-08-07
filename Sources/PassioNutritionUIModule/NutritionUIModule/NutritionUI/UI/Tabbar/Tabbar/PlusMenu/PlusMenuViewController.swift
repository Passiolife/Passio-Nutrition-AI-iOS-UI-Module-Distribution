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
        case createFood

        var image: UIImage? {
            switch self {
            case .recipe: UIImage.imageFromBundle(named: "Recipes")
            case .favourite: UIImage.imageFromBundle(named: "Heart")
            case .search: UIImage.imageFromBundle(named: "Search")
            case .scan: UIImage.imageFromBundle(named: "Scan")
            case .createFood: UIImage.imageFromBundle(named: "myFoods")
            }
        }
        var title: String? {
            switch self{
            case .recipe: Localized.recipes
            case .favourite: Localized.favorites
            case .search: Localized.textSearch
            case .scan: Localized.foodScan
            case .createFood: "My Foods"
            }
        }
    }

    private var menuData: [Rows] = [.createFood, .favourite, .search, .scan]

    weak var delegate: PlusMenuDelegate?
    var bottomCountedValue: CGFloat = 70.0

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        menuTableView.isHidden = true
        menuTableView.clipsToBounds = true

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
        dismiss(animated: true)
        switch menu{
        case .favourite:
            delegate?.onFavouritesSelected()
        case .recipe:
            delegate?.onRecipesSelected()
        case .scan:
            delegate?.onScanSelected()
        case .search:
            delegate?.onSearchSelected()
        case .createFood:
            delegate?.onMyFoodsSelected()
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
