//
//  MyFoodsSelectionViewController.swift
//  
//
//  Created by Nikunj Prajapati on 20/06/24.
//

import UIKit

class MyFoodsSelectionViewController: InstantiableViewController {

    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageCollectionView: PageCollectionView!
    @IBOutlet weak var pageContainerView: UIView! {
        willSet {
            addChild(pageViewController)
            newValue.addSubview(pageViewController.view)
            newValue.fitToSelf(childView: pageViewController.view)
            pageViewController.didMove(toParent: self)
        }
    }

    private let pageViewController = PageViewController([])
    private var viewControllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupBackButton()
    }

    // MARK: Configure
    private func configureUI() {

        title = "My Foods"
        pageCollectionView.titles = ["Custom Foods", "Recipes"]
        pageCollectionView.pageCollectionDelegate = self

        let customFoodsVC = CustomFoodsViewController(nibName: "CustomFoodsViewController", bundle: .module)
        let recipesVC = RecipesViewController(nibName: "RecipesViewController", bundle: .module)
        viewControllers = [customFoodsVC, recipesVC]
        pageViewController.pageDelegate = self
        pageViewController.isSwipeGestureEnabled(false)
        pageViewController.setup(viewControllers)

        indicatorLeadingConstraint.constant = 0
        indicatorWidthConstraint.constant = ScreenSize.width/2
        indicatorView.backgroundColor = .primaryColor
    }
}

// MARK: - PageViewDelegate
extension MyFoodsSelectionViewController: PageViewDelegate {

    func pageController(_ controller: PageViewController, didChangePage page: Int) {
        pageCollectionView.selectedCellIndexPath = IndexPath(item: page, section: 0)
        pageCollectionView.reloadData()
        setTabBarIndex(page)
    }

    // Helper
    private func setTabBarIndex(_ selectedIndex : Int) {

        pageViewController.setPage(selectedIndex, animated: true)
        UIView.animate(
            withDuration: 0.17,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.indicatorLeadingConstraint.constant = selectedIndex == 0 ? 0 : ScreenSize.width/2
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

// MARK: - PageViewDelegate
extension MyFoodsSelectionViewController: PageCollectionDelegate {

    func onPageSelection(index: Int) {
        setTabBarIndex(index)
    }
}
