//
//  CommonPickerViewController.swift
//  BaseApp
//
//  Created by Mind on 04/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit

protocol CommonPickerViewControllerDelegate: AnyObject {
    func pickerSelected(result: [Int]?)
}

final class CommonPickerViewController: UIViewController {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!

    var popupTitle: String?
    var data: [[String]] = [[]]
    var selectedIndexes: [Int]?
    weak var delegate: CommonPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        labelTitle.text = title ?? "NoTitle"
        buttonSave.setTitle(Localized.Ok, for: .normal)
        buttonCancel.setTitle(Localized.cancel, for: .normal)
        (selectedIndexes ?? []).enumerated().forEach { (index, value) in
            self.picker.selectRow(value, inComponent: index, animated: true)
        }
    }

    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func save(_ sender: UIButton) {
        var arraySelectedValue:[Int] = []
        for i in 0..<self.picker.numberOfComponents{
            arraySelectedValue.append(picker.selectedRow(inComponent: i))
        }
        
        delegate?.pickerSelected(result: arraySelectedValue)
        self.dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDataSource
extension CommonPickerViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        data.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        data[component].count
    }
}

// MARK: - UIPickerViewDelegate
extension CommonPickerViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = .gray900
        pickerLabel.text = data[component][row]
        pickerLabel.font = UIFont.inter(type: .regular, size: 20)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        26.0
    }
}
