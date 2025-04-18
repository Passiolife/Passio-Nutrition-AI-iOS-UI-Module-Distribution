//
//  HalfBottomShitViewController.swift
//  BaseApp
//
//  Created by Mind on 22/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class CustomModalViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var viewDragMain: UIView!
    @IBOutlet var containerViewHeightConstraint: NSLayoutConstraint?
    // Constants
    let defaultHeight: CGFloat = 0
    let dismissibleHeight: CGFloat = -100
    var maximumContainerHeight: CGFloat = 200
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 0

    var shouldShowMiniOnly: Bool = true {
        didSet {
            containerViewHeightConstraint?.constant = 0
        }
    }

    var isExpanded: Bool = false
    var isDraggable: Bool = true
    var isDraggingStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()

        containerViewHeightConstraint?.constant = 0
        setupPanGesture()
    }

    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePanGesture(gesture:)))
        panGesture.cancelsTouchesInView = false
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        self.containerView.addGestureRecognizer(panGesture)
    }

    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {

        if shouldShowMiniOnly || !isDraggable {
            return
        }

        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa

        // Get drag direction
        let isDraggingDown = translation.y > 0

        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y

        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            if !isDraggingStarted {
                isDraggingStarted = true
            }
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            } else if newHeight < dismissibleHeight {
                // Dimiss -----------
                isDraggingStarted = false
            }
        case .ended:
            if newHeight < dismissibleHeight {
                isDraggingStarted = false
                isExpanded = false
            } else if newHeight < defaultHeight {
                isDraggingStarted = false
                isExpanded = false
                animateContainerHeight(defaultHeight)
            } else if newHeight < maximumContainerHeight && isDraggingDown {
                isDraggingStarted = false
                isExpanded = false
                animateContainerHeight(defaultHeight)
            } else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
                isExpanded = true
            }
        default:
            break
        }
    }

    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self else { return }
            containerViewHeightConstraint?.constant = height
            view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
}
