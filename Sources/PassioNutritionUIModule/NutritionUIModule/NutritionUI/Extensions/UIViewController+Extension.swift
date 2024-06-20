//
//  UIViewControllerExtension.swift
//  Passio App Module
//
//  Created by zvika on 1/28/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit

public extension UIViewController {

    func setupBackButton() {

        // setupInteractivePopGestureRecognizer()
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage.imageFromBundle(named: "back_arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
    }

    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }

//    open override func awakeAfter(using coder: NSCoder) -> Any? {
//        navigationItem.backButtonDisplayMode = .minimal // This will help us to remove text from back button
//        return super.awakeAfter(using: coder)
//    }

    /// Customize Navigation bar
//    func customizeNavigationBar(tintColor: UIColor = .gray400,
//                                titleColor: UIColor = .gray900,
//                                withBackButton: Bool = true) {
//
//        guard let navBar = self.navigationController?.navigationBar else { return }
//        navBar.setBackgroundImage(nil, for: .default)
//        navBar.shadowImage = UIImage()
//        navBar.tintColor = tintColor
//
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithTransparentBackground()
//        appearance.titleTextAttributes = [.font: UIFont.inter(type: .bold, size: 23),
//                                          .foregroundColor: titleColor]
//        navBar.standardAppearance = appearance
//        navBar.scrollEdgeAppearance = appearance
//        navBar.tintColor = tintColor
//        addEmptyleftButon()
//        if !withBackButton {
//            navigationItem.hidesBackButton = true
//        }
//    }

    var topBarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }

    func presentVC(vc: UIViewController, isAnimated: Bool = true) {
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: isAnimated)
    }

    func getMeasurementUnit() -> UnitSelection {
        let isMetric = Locale.current.usesMetricSystem
        let unit = isMetric ? UnitSelection.metric : .imperial
        return unit
    }

    func showMessage(msg: String,
                     duration: CGFloat = 1,
                     delay: CGFloat = 1,
                     bgColor: UIColor = .black,
                     width: CGFloat = ScreenSize.width - 32,
                     y: CGFloat = 16,
                     alignment: UIStackView.Alignment = .bottom) {

        let height: CGFloat = 50
        var yPosition: CGFloat = y

        switch alignment {
        case .bottom:
            yPosition = view.frame.height - y
        case .top:
            yPosition = y
        case .center:
            yPosition = view.frame.height/2
        default:
            yPosition = view.frame.height - y
        }
        let frame = CGRect(x: (view.frame.width - width)/2,
                           y: yPosition,
                           width: width,
                           height: height)

        let addedToLog = AddedToLogView(frame: frame, withText: msg, bgColor: bgColor)

        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            keyWindow.addSubview(addedToLog)
            addedToLog.removeAfter(withDuration: duration, delay: delay)
        }
    }

    func createActivityIndicator(themeColor: UIColor = .white) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.tintColor = themeColor
        activityIndicator.color = themeColor
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        return activityIndicator
    }

    func showAlertController(alertType: UIAlertController.Style,
                             alertTitle: String? = nil,
                             alertMessage: String? = nil,
                             actionTitle: String,
                             themeColor: UIColor = .blue0D1,
                             actionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: alertType)
        alert.view.tintColor = themeColor
        alert.addAction(UIAlertAction(title: actionTitle,
                                      style: .destructive,
                                      handler: actionHandler))
        alert.addAction(UIAlertAction(title: Localized.cancel,
                                      style: .cancel))
        present(alert, animated: true, completion: nil)
    }

    internal func showCustomAlert(with views: CustomAlert = CustomAlert(),
                                  title: CustomAlert.AlertTitle,
                                  font: CustomAlert.AlertFont,
                                  delegate: CustomAlertDelegate?) {
        let customAlertVC = CustomAlertViewController(nibName: "CustomAlertViewController",
                                                      bundle: .module)
        customAlertVC.loadViewIfNeeded()
        customAlertVC.configureAlert(views: views)
        customAlertVC.configureAlert(title: title)
        customAlertVC.configureAlert(font: font)
        customAlertVC.delegate = delegate
        customAlertVC.modalTransitionStyle = .crossDissolve
        customAlertVC.modalPresentationStyle = .overFullScreen
        navigationController?.present(customAlertVC, animated: true)
    }

    func showAlertForError(alertTitle: String,
                           textColor: UIColor = .black,
                           actionHandler: ((UIAlertAction) -> Void)? = nil) {
        let attributedString = NSAttributedString(string: alertTitle,
                                                  attributes: [.font: UIFont.systemFont(ofSize: 17,
                                                                                        weight: .medium),
                                                               .foregroundColor: textColor])
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.addAction(UIAlertAction(title: Localized.Ok, style: .cancel, handler: actionHandler))
        present(alert, animated: true, completion: nil)
    }

    func showAlertWith(titleKey: String,
                       messageKey: String? = nil,
                       view: UIViewController) {
        let title = titleKey.localized
        var message: String?
        if let msg = messageKey {
            message = msg.localized
        }
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: Localized.Ok, style: .cancel)
        alert.addAction(action)
        view.present(alert, animated: true)
    }

    func showActivityViewController(items: [Any],
                                    completionHandler: ((UIActivity.ActivityType?,
                                                         Bool,
                                                         [Any]?,
                                                         Error?) -> Void)? = nil) {
        let activityController = UIActivityViewController(activityItems: items,
                                                          applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = view
        activityController.popoverPresentationController?.sourceRect = view.frame
        activityController.completionWithItemsHandler = completionHandler
        present(activityController, animated: true, completion: nil)
    }

    func getRectsForFrontView(fullRect: CGRect) -> [CGRect] {

        let topSpacing: CGFloat =  50 // fridgeRect.origin.y + 50
        let leftSpacing: CGFloat =  0 // fridgeRect.origin.x
        let shelfWidth: CGFloat = fullRect.width
        let overlapHeight: CGFloat = 100
        let shelfHeight: CGFloat = (400/1452)*fullRect.height
        let sliceWidth: CGFloat = shelfWidth/3 + overlapHeight
        let sliceHeight: CGFloat = shelfHeight + overlapHeight

        let firstshelfRect = CGRect(
            x: leftSpacing,
            y: topSpacing,
            width: shelfWidth,
            height: shelfHeight
        )

        let firstSlice = CGRect(
            x: firstshelfRect.origin.x,
            y: firstshelfRect.origin.y,
            width: sliceWidth,
            height: sliceHeight
        )

        let secondSlice = CGRect(
            x: firstSlice.origin.x + firstSlice.size.width - 2*overlapHeight,
            y: firstshelfRect.origin.y,
            width: sliceWidth,
            height: sliceHeight
        )

        let thirdSlice = CGRect(
            x: secondSlice.origin.x + secondSlice.size.width - 2*overlapHeight,
            y: firstshelfRect.origin.y,
            width: sliceWidth + 50,
            height: sliceHeight
        )

        let secondShelfRect = CGRect(
            x: leftSpacing,
            y: firstshelfRect.origin.y + firstshelfRect.size.height - overlapHeight,
            width: shelfWidth,
            height: shelfHeight
        )

        let fourthSlice = CGRect(
            x: secondShelfRect.origin.x,
            y: secondShelfRect.origin.y,
            width: sliceWidth,
            height: sliceHeight
        )

        let fiveSlice = CGRect(
            x: fourthSlice.origin.x + fourthSlice.size.width - 2*overlapHeight,
            y: secondShelfRect.origin.y,
            width: sliceWidth,
            height: sliceHeight
        )

        let sixSlice = CGRect(
            x: fiveSlice.origin.x + fiveSlice.size.width - 2*overlapHeight,
            y: secondShelfRect.origin.y,
            width: sliceWidth + 50,
            height: sliceHeight
        )

        let thirdShelfRect = CGRect(
            x: leftSpacing,
            y: secondShelfRect.origin.y + secondShelfRect.size.height - overlapHeight,
            width: shelfWidth,
            height: shelfHeight
        )

        let sevenSlice = CGRect(
            x: thirdShelfRect.origin.x,
            y: thirdShelfRect.origin.y,
            width: sliceWidth,
            height: sliceHeight
        )

        let eightSlice = CGRect(
            x: sevenSlice.origin.x + sevenSlice.size.width - 2*overlapHeight,
            y: thirdShelfRect.origin.y,
            width: sliceWidth,
            height: sliceHeight
        )

        let nineSlice = CGRect(
            x: eightSlice.origin.x + eightSlice.size.width - 2*overlapHeight,
            y: thirdShelfRect.origin.y,
            width: sliceWidth + 50,
            height: sliceHeight
        )

        return [
            firstSlice,
            secondSlice,
            thirdSlice,
            fourthSlice,
            fiveSlice,
            sixSlice,
            sevenSlice,
            eightSlice,
            nineSlice
        ]
    }
}

//public protocol InteractivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate {
//    func setupInteractivePopGestureRecognizer()
//}
//
//extension InteractivePopGestureRecognizerDelegate where Self: UIViewController {
//    public func setupInteractivePopGestureRecognizer() {
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
//    }
//}
//
//extension UIViewController: InteractivePopGestureRecognizerDelegate {
//    // Ensure the gesture recognizer works alongside the custom back button
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return navigationController?.viewControllers.count ?? 0 > 1
//    }
//}
