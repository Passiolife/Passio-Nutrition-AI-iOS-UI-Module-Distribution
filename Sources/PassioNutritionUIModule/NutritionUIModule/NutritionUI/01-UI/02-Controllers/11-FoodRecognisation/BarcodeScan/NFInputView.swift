//
//  NFInputView.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 23/05/25.
//

import UIKit

protocol DoneButtonDelegate: AnyObject {
    func doneTapped()
}

class NFInputView: UIView
{
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tfContainerView: UIView!

    weak var delegate: DoneButtonDelegate?

    func configure(title: String = "",
                   unit: String = "",
                   tag: Int = 0,
                   tfDelegate: UITextFieldDelegate? = nil,
                   doneDelegate: DoneButtonDelegate? = nil) {
        self.title = title
        self.unit = unit
        self.textField.tag = tag
        self.delegate = doneDelegate
        self.textField.delegate = tfDelegate
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var unit: String = "" {
        didSet {
            updateUnit()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.module.loadNibNamed("NFInputView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        basicSetup()
    }
    
    private func basicSetup() {
        tfContainerView.layer.cornerRadius = tfCornerRadius
        tfContainerView.layer.borderColor = tfBorderColor.cgColor
        tfContainerView.layer.borderWidth = tfBorderWidth
        unitLabel.textColor = .rgb(180, 182, 190)
        updateUnit()
        textField.addDoneButtonToKeyboard(target: self, action: #selector(doneButtonTapped))
    }
    
    @objc private func doneButtonTapped() {
        textField.resignFirstResponder()
        delegate?.doneTapped()
    }    
    
    func updateUnit() {
        if unit.count > 0 {
            unitLabel.isHidden = false
            unitLabel.text = unit
        } else {
            unitLabel.isHidden = true
        }
    }
}

extension NFInputView {
    func setValid(_ isValid: Bool) {
        if isValid {
            tfContainerView.layer.borderColor = tfBorderColor.cgColor
        } else {
            tfContainerView.layer.borderColor = tfInvalidBorderColor.cgColor
        }
    }
}
