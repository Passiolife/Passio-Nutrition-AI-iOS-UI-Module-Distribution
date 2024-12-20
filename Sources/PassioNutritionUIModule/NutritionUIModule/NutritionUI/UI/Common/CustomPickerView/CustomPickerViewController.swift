//
//  CustomPickerViewController.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 23/06/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

public protocol CustomPickerSelectionDelegate: AnyObject {
    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int)
}

public struct PickerElement {
    var title: String?
    var image: UIImage?
    
    public init(title: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.image = image
    }
}

final public class CustomPickerViewController: InstantiableViewController {

    @IBOutlet weak var pickerTableView: UITableView!

    public var viewTag = 0
    public var disableCapatlized: Bool = false
    public var pickerItems = [PickerElement]() {
        didSet {
            pickerTableView.reloadData()
        }
    }
    public var pickerFrame = CGRect(x: 110, y: 100, width: 288, height: 290) {
        didSet {
            pickerTableView.frame = pickerFrame.height > 358 ? CGRect(x: pickerFrame.origin.x,
                                                          y: pickerFrame.origin.y,
                                                          width: pickerFrame.width,
                                                          height: 358) : pickerFrame
        }
    }

    public weak var delegate: CustomPickerSelectionDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    @IBAction func onDismissButtonClicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Configure UI
extension CustomPickerViewController {

    private func configureUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        pickerTableView.roundMyCornerWith(radius: 8)
        pickerTableView.estimatedRowHeight = UITableView.automaticDimension
        pickerTableView.frame = pickerFrame
        pickerTableView.dataSource = self
        pickerTableView.delegate = self
        pickerTableView.register(nibName: "CustomPickerCell")
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CustomPickerViewController: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pickerItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueCell(cellClass: CustomPickerCell.self, forIndexPath: indexPath)
        let element = pickerItems[indexPath.row]
        let title = (element.title ?? "")
        cell.pickerName.text = disableCapatlized ? title : title == "ml" ? title : title.capitalized
        cell.pickerImageView.image = element.image
        cell.pickerImageView.isHidden = element.image == nil
        cell.pickerImageView.tintColor = .primaryColor
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.onPickerSelection(value: pickerItems[indexPath.row].title ?? "",
                                        selectedIndex: indexPath.row,
                                        viewTag: viewTag)
        }
    }
}
