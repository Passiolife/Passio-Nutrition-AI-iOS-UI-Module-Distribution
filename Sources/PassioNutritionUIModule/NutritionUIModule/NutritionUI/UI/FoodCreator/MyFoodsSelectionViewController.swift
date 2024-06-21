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
    @IBOutlet weak var shadowView: UIView!
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

        let createFoodsVC = CreateFoodViewController(nibName: "CreateFoodViewController", bundle: .module)
        let recipesVC = RecipesViewController(nibName: "RecipesViewController", bundle: .module)
        viewControllers = [createFoodsVC, recipesVC]
        pageViewController.pageDelegate = self
        pageViewController.setup(viewControllers)

        indicatorLeadingConstraint.constant = 0
        indicatorWidthConstraint.constant = ScreenSize.width/2
    }
}

// MARK: - PageViewDelegate
extension MyFoodsSelectionViewController: PageViewDelegate {

    func pageControllerDidScroll(offset: CGFloat, currentPage: Int) {
//        let indicatorWidth = ScreenSize.width/2
//        if currentPage == 1 && offset < indicatorWidth { return }
//        if offset > indicatorWidth { return }
        // indicatorLeadingConstraint.constant = offset
    }

    func pageController(_ controller: PageViewController, didChangePage page: Int) {
        pageCollectionView.selectedCellIndexPath = IndexPath(item: page, section: 0)
        pageCollectionView.reloadData()
        setTabBarIndex(page)
    }

    // Helper
    private func setTabBarIndex(_ selectedIndex : Int) {

        pageViewController.setPage(selectedIndex, animated: true)
        indicatorLeadingConstraint.constant = selectedIndex == 0 ? 0 : ScreenSize.width/2
//        UIView.animate(withDuration: 0.12,
//                       delay: 0,
//                       options: .beginFromCurrentState,
//                       animations: { [self] in
//            indicatorLeadingConstraint.constant = selectedIndex == 0 ? 0 : ScreenSize.width/2
//            view.layoutIfNeeded()
//        })
    }
}

// MARK: - PageViewDelegate
extension MyFoodsSelectionViewController: PageCollectionDelegate {

    func onPageSelection(index: Int) {
        setTabBarIndex(index)
    }
}
