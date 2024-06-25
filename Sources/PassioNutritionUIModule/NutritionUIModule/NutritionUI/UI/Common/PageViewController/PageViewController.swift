//
//  PageViewController.swift
//  
//
//  Created by Nikunj Prajapati on 21/06/24.
//

import UIKit

public protocol PageViewDelegate: AnyObject {
    func pageController(_ controller: PageViewController, didChangePage page: Int)
}

public final class PageViewController: UIPageViewController {

    public var currentViewController: UIViewController {
        return viewControllerList[currentPage]
    }
    public private(set) var viewControllerList = [UIViewController]()
    public private(set) var currentPage = 0 {
        didSet {
            pageDelegate?.pageController(self, didChangePage: currentPage)
        }
    }
    public weak var pageDelegate: PageViewDelegate?

    // MARK: init
    public init(_ viewControllerList: [UIViewController] = [],
                transitionStyle: UIPageViewController.TransitionStyle = .scroll,
                navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal) {
        super.init(transitionStyle: transitionStyle, navigationOrientation: navigationOrientation, options: nil)

        // Find the scroll view and set its delegate
        for view in view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delaysContentTouches = false
                break
            }
        }
        dataSource = self
        delegate = self
        setup(viewControllerList)
    }

    func isSwipeGestureEnabled(_ isScrollEnabled: Bool = true) {
        for view in view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = isScrollEnabled
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configuration
extension PageViewController {

    public func setup(_ controllers: [UIViewController]) {
        guard !controllers.isEmpty else {
            return
        }
        viewControllerList = controllers
        setViewControllers([viewControllerList[currentPage]],
                           direction: .forward,
                           animated: false,
                           completion: nil)
    }

    public func setPage(_ page: Int, animated: Bool = false) {
        guard currentPage != page else {
            return
        }
        setViewControllers([viewControllerList[page]],
                           direction: pageDirection(from: page),
                           animated: animated,
                           completion: nil)
        currentPage = page
    }
}

// MARK: - Direction
extension PageViewController {

    private func pageDirection(from page: Int) -> UIPageViewController.NavigationDirection {
        normalPageDirection(from: page)
    }

    private func normalPageDirection(from page: Int) -> UIPageViewController.NavigationDirection {
        currentPage < page ? .forward : .reverse
    }
}

// MARK: - Index
extension PageViewController {

    private func nextIndex(from current: UIViewController) -> Int? {
        guard let currentIndex = viewControllerList.firstIndex(of: current) else {
            return nil
        }
        return normalNextIndex(from: currentIndex)
    }

    private func normalNextIndex(from currentIndex: Int) -> Int? {
        let nextIndex = currentIndex + 1
        return nextIndex >= viewControllerList.count ? nil : nextIndex
    }

    private func previousIndex(from current: UIViewController) -> Int? {
        guard let currentIndex = viewControllerList.firstIndex(of: current) else {
            return nil
        }
        return normalPreviousIndex(from: currentIndex)
    }

    private func normalPreviousIndex(from currentIndex: Int) -> Int? {
        let previousIndex = currentIndex - 1
        return previousIndex < 0 ? nil : previousIndex
    }

    private func infinitePreviousIndex(from currentIndex: Int) -> Int? {
        let previousIndex = currentIndex - 1
        return previousIndex < 0 ? viewControllerList.count - 1 : previousIndex
    }
}

// MARK: - UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let previousIndex = previousIndex(from: viewController) {
            return viewControllerList[previousIndex]
        }
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let nextIndex = nextIndex(from: viewController) {
            return viewControllerList[nextIndex]
        }
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        let current = pageViewController.viewControllers![0]
        currentPage = viewControllerList.firstIndex(of: current)!
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
