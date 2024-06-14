//
//  HalfBottomShitViewController.swift
//  BaseApp
//
//  Created by Mind on 22/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit

class CustomModalViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var viewDragMain: UIView!
    // Constants
    let defaultHeight: CGFloat = 0
    let dismissibleHeight: CGFloat = -100
    var maximumContainerHeight: CGFloat = 200
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 0
    
    var shouldShowMiniOnly: Bool = true{
        didSet {
            containerViewHeightConstraint?.constant = 0
        }
    }
    
    var isExpanded: Bool = false
    var isDraggable: Bool = true
    // Dynamic container constraint
    @IBOutlet var containerViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerViewHeightConstraint?.constant = 0
        setupPanGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.cancelsTouchesInView = false
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        self.containerView.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if shouldShowMiniOnly || !isDraggable{
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
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }else   if newHeight < dismissibleHeight {
                // Dimiss -----------
            }
        case .ended:
            if newHeight < dismissibleHeight {
                self.isExpanded = false
            }
            else if newHeight < defaultHeight {
                self.isExpanded = false
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                self.isExpanded = false
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
                self.isExpanded = true
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
}
