//
//  ViewForXib.swift
//  Nutritaion-ai
//
//  Created by Mind on 12/02/24.
//

import UIKit

class ViewFromXIB: UIView {

    var customView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit(emptyCheck: true)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit(emptyCheck: false)
    }

    func commonInit(emptyCheck: Bool) -> Void {

        self.clipsToBounds = false
        self.backgroundColor = .clear

        let className = String(describing: type(of: self).self)
        customView = Bundle.module.loadNibNamed(className, owner: self, options: nil)?.first as? UIView
        customView.frame = self.bounds
        if emptyCheck {
            if frame.isEmpty {
                self.bounds = customView.bounds
            }
        }
        self.addSubview(customView)
    }
}


public protocol PageMasterDelegate: AnyObject {
    func pageMaster(_ master: PageMaster, didChangePage page: Int)
}

public final class PageMaster: UIPageViewController {

    public private(set) var viewControllerList = [UIViewController]()

    public private(set) var currentPage = 0 {
        didSet {
            self.pageDelegate?.pageMaster(self, didChangePage: self.currentPage)
        }
    }

    public var currentViewController: UIViewController {
        return self.viewControllerList[currentPage]
    }

    public var isInfinite = false

    public weak var pageDelegate: PageMasterDelegate?

    public init(_ viewControllerList: [UIViewController] = [], transitionStyle: UIPageViewController.TransitionStyle = .scroll, navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal) {
        super.init(transitionStyle: transitionStyle, navigationOrientation: navigationOrientation, options: nil)
        self.view.subviews.forEach { ($0 as? UIScrollView)?.delaysContentTouches = false }
        self.dataSource = self
        self.delegate = self
        self.setup(viewControllerList)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public
extension PageMaster {

    public func setup(_ viewControllerList: [UIViewController]) {
        guard !viewControllerList.isEmpty else {
            return
        }
        self.viewControllerList = viewControllerList
        self.setViewControllers([self.viewControllerList[self.currentPage]], direction: .forward, animated: false, completion: nil)

    }

    public func setPage(_ page: Int, animated: Bool = false) {
        guard self.currentPage != page else {
            return
        }
        self.setViewControllers([self.viewControllerList[page]], direction: self.pageDirection(from: page), animated: animated, completion: nil)
        self.currentPage = page
    }

}

// MARK: - Direction
extension PageMaster {

    private func pageDirection(from page: Int) -> UIPageViewController.NavigationDirection {
        if self.isInfinite {
            return self.infinitePageDirection(from: page)
        }
        else {
            return self.normalPageDirection(from: page)
        }
    }

    private func normalPageDirection(from page: Int) -> UIPageViewController.NavigationDirection {
        if self.currentPage < page {
            return .forward
        }
        else {
            return .reverse
        }
    }

    private func infinitePageDirection(from page: Int) -> UIPageViewController.NavigationDirection {
        let lastPage = self.viewControllerList.count - 1
        if self.currentPage == lastPage && page == 0 {
            return .forward
        }

        if self.currentPage == 0 && page == lastPage {
            return .reverse
        }

        return self.normalPageDirection(from: page)
    }
}

// MARK: - Index
extension PageMaster {

    private func nextIndex(from current: UIViewController) -> Int? {
        guard let currentIndex = self.viewControllerList.firstIndex(of: current) else {
            return nil
        }

        if self.isInfinite {
            return self.infiniteNextIndex(from: currentIndex)
        }
        else {
            return self.normalNextIndex(from: currentIndex)
        }
    }

    private func normalNextIndex(from currentIndex: Int) -> Int? {
        let nextIndex = currentIndex + 1
        if nextIndex >= self.viewControllerList.count {
            return nil
        }
        else {
            return nextIndex
        }
    }

    private func infiniteNextIndex(from currentIndex: Int) -> Int? {
        let nextIndex = currentIndex + 1
        if nextIndex >= self.viewControllerList.count {
            return 0
        }
        else {
            return nextIndex
        }
    }

    private func previousIndex(from current: UIViewController) -> Int? {
        guard let currentIndex = self.viewControllerList.firstIndex(of: current) else {
            return nil
        }

        if self.isInfinite {
            return self.infinitePreviousIndex(from: currentIndex)
        }
        else {
            return self.normalPreviousIndex(from: currentIndex)
        }
    }

    private func normalPreviousIndex(from currentIndex: Int) -> Int? {
        let previousIndex = currentIndex - 1
        if previousIndex < 0 {
            return nil
        }
        else {
            return previousIndex
        }
    }

    private func infinitePreviousIndex(from currentIndex: Int) -> Int? {
        let previousIndex = currentIndex - 1
        if previousIndex < 0 {
            return self.viewControllerList.count - 1
        }
        else {
            return previousIndex
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension PageMaster: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let previousIndex = self.previousIndex(from: viewController) {
            return self.viewControllerList[previousIndex]
        }
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let nextIndex = self.nextIndex(from: viewController) {
            return self.viewControllerList[nextIndex]
        }
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let current = pageViewController.viewControllers![0]
        self.currentPage = self.viewControllerList.firstIndex(of: current)!
    }
}

extension UIPageViewController {

    var isPagingEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}
