//
//  ProgressViewController.swift
//  BaseApp
//
//  Created by Mind on 29/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {

    @IBOutlet weak var progressSelectionView: UIView!
    @IBOutlet weak var macrosButton: UIButton!
    @IBOutlet weak var microButton : UIButton!
    @IBOutlet weak var segmentUnderlineView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pageFrameView : UIView! {
        willSet {
            addChild(pageMaster)
            newValue.addSubview(pageMaster.view)
            newValue.fitToSelf(childView: pageMaster.view)
            pageMaster.didMove(toParent: self)
        }
    }

    private let pageMaster = PageViewController([])
    private var viewControllerList: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPageViewController()
    }

    func setupUI() {
        [macrosButton, microButton].forEach {
            $0?.setTitleColor(.gray900, for: .normal)
            $0?.setTitleColor(.primaryColor, for: .selected)
        }
        macrosButton.isSelected = true
        microButton.isSelected = false
        progressSelectionView.backgroundColor = .navigationColor
        segmentUnderlineView.backgroundColor = .primaryColor
    }

    private func setupPageViewController() {
        let macroViewController = UIStoryboard(name: "Progress",
                                               bundle: PassioInternalConnector.shared.bundleForModule)
            .instantiateViewController(identifier: "MacroProgressViewController") as! MacroProgressViewController
        let microViewController = UIStoryboard(name: "Progress",
                                               bundle: PassioInternalConnector.shared.bundleForModule)
            .instantiateViewController(identifier: "MicroProgressViewController") as! MicroProgressViewController
        viewControllerList = [macroViewController, microViewController]
        pageMaster.pageDelegate = self
        pageMaster.setup(viewControllerList)
    }

    private func setTabBarIndex(_ selectedIndex : Int) {

        pageMaster.setPage(selectedIndex, animated: true)

        let buttons = [macrosButton, microButton].compactMap{ $0 }
        for button in buttons {
            button.isSelected = button.tag == selectedIndex
            button.titleLabel?.font = button.tag == selectedIndex ?
            UIFont.inter(type: .semiBold, size: 20) : UIFont.inter(type: .regular, size: 20)
        }
        UIView.animate(withDuration: 0.3) {
            self.leadingConstraint.constant = CGFloat(selectedIndex) * ScreenSize.width * 0.5
            self.segmentUnderlineView.layoutIfNeeded()
        }
    }

    @IBAction func setTab(_ sender: UIButton) {
        setTabBarIndex(sender.tag)
    }
}

// MARK: - PageViewDelegate
extension ProgressViewController: PageViewDelegate {

    func pageControllerDidScroll(offset: CGFloat, currentPage: Int) { }

    func pageController(_ controller: PageViewController, didChangePage page: Int) {
        setTabBarIndex(page)
    }
}
