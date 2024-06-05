//
//  UIViewControllerExtension.swift
//  Passio App Module
//
//  Created by zvika on 1/28/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit

public extension UIViewController {

    func configureNavBarWithImage(named: String = "header_bg", withColor: UIColor = .white ) {
        if let navBar = self.navigationController?.navigationBar {
            let textAttributes = [NSAttributedString.Key.foregroundColor: withColor]
            navBar.backgroundColor = .passioBackgroundWhite
            navBar.titleTextAttributes = textAttributes
            navBar.tintColor = withColor
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized,
                                                               style: .plain,
                                                               target: nil,
                                                               action: nil)
        }
    }

    func configureCameraNavBar(withColor: UIColor = .white) {
        if let navBar = self.navigationController?.navigationBar {
            let textAttributes = [NSAttributedString.Key.foregroundColor: withColor]
            navBar.backgroundColor = .passioBackgroundWhite
            navBar.titleTextAttributes = textAttributes
            navBar.tintColor = withColor
            navBar.isTranslucent = true
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized,
                                                               style: .plain,
                                                               target: nil,
                                                               action: nil)
        }
    }

    func configureWhiteBarNoImage() {
        if let navBar = self.navigationController?.navigationBar {
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            navBar.titleTextAttributes = textAttributes
            navBar.tintColor = .black
            navBar.isTranslucent = true
            navBar.barStyle = .default
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized,
                                                               style: .plain,
                                                               target: nil,
                                                               action: nil)
        }
    }

    func setupBackButton() {
        let barButton = UIBarButtonItem(image: UIImage.imageFromBundle(named: "back_arrow"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(back))
        self.navigationItem.leftBarButtonItem = barButton
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
    //        self.setupBackButton() // This will help us to remove text from back button
    //        return super.awakeAfter(using: coder)
    //    }
    //
    func setGradientBackground() {
        let layer0 = CAGradientLayer()
        layer0.colors = [UIColor(red: 0, green: 0.706, blue: 0.776, alpha: 1).cgColor,
                         UIColor(red: 0.008, green: 0.059, blue: 0.522, alpha: 1).cgColor]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0))
        layer0.frame = CGRect(x: 0,
                              y: 0,
                              width: ScreenSize.width,
                              height: ScreenSize.height)
        layer0.position = view.center
        view.layer.insertSublayer(layer0, at: 0)
    }

    var topBarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }

    func navigateTo(vc: UIViewController, hideTabBar: Bool = true) {
        vc.hidesBottomBarWhenPushed = hideTabBar ? true : false
        self.navigationController?.pushViewController(vc, animated: true)
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
