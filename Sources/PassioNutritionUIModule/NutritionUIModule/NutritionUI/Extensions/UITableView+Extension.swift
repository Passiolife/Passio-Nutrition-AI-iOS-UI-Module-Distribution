//
//  UITableView+Extention.swift
//  BaseApp
//
//  Created by zvika on 5/6/20.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

public extension UITableView {

    func reloadWithAnimations(withDuration: Double = 0.5) {
        UIView.transition(with: self, duration: withDuration,
                          options: [.transitionCrossDissolve, .allowUserInteraction],
                          animations: {
            self.reloadData()
        })
    }

    func dequeueCell<T: UITableViewCell>(cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable TableView Cell")
        }
        return cell
    }

    func register(nibName: String, bundle: Bundle = PassioInternalConnector.shared.bundleForModule) {
        register(UINib.nibFromBundle(nibName: nibName, bundle: bundle), forCellReuseIdentifier: nibName)
    }

    func registerHeaderFooter<T: UITableViewHeaderFooterView>(
        _ viewClass: T.Type) {
            self.register(UINib.nibFromBundle(nibName: "\(viewClass)"), forHeaderFooterViewReuseIdentifier: "\(viewClass)")
        }
    
    func dequeueHeaderFooter<T: UITableViewHeaderFooterView>(_ view : T.Type) -> T {
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: "\(view)") as? T else {
            fatalError("Error: cell with identifier: \(view) is not \(T.self)")
        }
        return view
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

public extension UITableViewCell {

    static var identifier: String {
        return String(describing: self)
    }
}
