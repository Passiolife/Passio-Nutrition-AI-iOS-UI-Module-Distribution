//
//  CustomAlertViewController.swift
//
//
//  Created by Nikunj Prajapati on 19/06/24.
//

import UIKit

protocol CustomAlertDelegate: AnyObject {
    func onRightButtonTapped(textValue: String?)
    func onleftButtonTapped()
}

struct CustomAlert {

    var headingLabel: Bool = true
    var titleLabel: Bool = false
    var alertTextField: Bool = true
    var rightButton: Bool = false
    var leftButton: Bool = false

    struct AlertTitle {
        var headingText: String = ""
        var titleText: String = ""
        var textFieldPlaceholder: String = ""
        var rightButtonTitle: String = ""
        var leftButtonTitle: String = "Cancel"
    }

    struct AlertFont {
        var headingFont: UIFont = .inter(type: .bold, size: 20)
        var titleFont: UIFont = .inter(type: .regular, size: 14)
        var textFieldPlaceholderFont: UIFont = .inter(type: .regular, size: 16)
        var textFieldFont: UIFont = .inter(type: .regular, size: 16)
        var rightButtonFont: UIFont = .inter(type: .medium, size: 16)
        var leftButtonFont: UIFont = .inter(type: .medium, size: 16)
    }

    struct AlertColor {
        var headingColor: UIColor = .gray900
        var titleColor: UIColor = .gray900
        var textFieldColor: UIColor = .gray900
        var rightButtonColor: UIColor = .white
        var leftButtonColor: UIColor = .indigo600
        var borderColor: UIColor = .indigo600
        var isBorderEnabled: Bool = true
        var isLeftBorder: Bool = true
        var isRightBorder: Bool = false
    }
}

class CustomAlertViewController: InstantiableViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alertTextField: UITextField!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var viewYConstraint: NSLayoutConstraint!
    
    weak var delegate: CustomAlertDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white.withAlphaComponent(0.5)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        contentView.dropShadow(radius: 8,
                               offset: .init(width: 1, height: 1),
                               color: .black.withAlphaComponent(0.3),
                               shadowRadius: 4,
                               shadowOpacity: 1)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds,
                                                    cornerRadius: 8).cgPath
    }

    func configureAlert(views: CustomAlert = CustomAlert()) {
        headingLabel.isHidden = views.headingLabel
        titleLabel.isHidden = views.titleLabel
        alertTextField.isHidden = views.alertTextField
        rightButton.isHidden = views.rightButton
        leftButton.isHidden = views.leftButton

        if !alertTextField.isHidden {
            alertTextField.delegate = self
            rightButton.alpha = 0.5
            rightButton.isEnabled = false
        }
    }

    func configureAlert(title: CustomAlert.AlertTitle = CustomAlert.AlertTitle()) {
        headingLabel.text = title.headingText
        titleLabel.text = title.titleText
        alertTextField.placeholder = title.textFieldPlaceholder
        rightButton.setTitle(title.rightButtonTitle, for: .normal)
        leftButton.setTitle(title.leftButtonTitle, for: .normal)
    }

    func configureAlert(font: CustomAlert.AlertFont = CustomAlert.AlertFont()) {
        headingLabel.font = font.headingFont
        titleLabel.font = font.titleFont
        alertTextField.attributedPlaceholder = "Enter a name".setAttributedString(
            font: .inter(type: .regular,
                         size: 16),
            textColor: .gray500
        )
        rightButton.titleLabel?.font = font.rightButtonFont
        leftButton.titleLabel?.font = font.leftButtonFont
    }

    func configureAlert(color: CustomAlert.AlertColor = CustomAlert.AlertColor()) {
        headingLabel.textColor = color.headingColor
        titleLabel.textColor = color.titleColor
        alertTextField.textColor = color.textFieldColor
        rightButton.setTitleColor(color.rightButtonColor, for: .normal)
        leftButton.setTitleColor(color.leftButtonColor, for: .normal)

        if color.isBorderEnabled, color.isRightBorder {
            rightButton.backgroundColor = .white
            rightButton.applyBorder(width: 2, color: .systemRed)
            leftButton.applyBorder(width: 0, color: .clear)
            leftButton.backgroundColor = .indigo600
            leftButton.setTitleColor(.white, for: .normal)
        }
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        UIView.animate(withDuration: 0.21) {
            self.viewYConstraint.constant = -100
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.21) {
            self.viewYConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func onRightButton(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.onRightButtonTapped(textValue: self?.alertTextField.text)
        }
    }

    @IBAction func onLeftButton(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.onleftButtonTapped()
        }
    }

    @IBAction func onTextFieldValueChanged(_ sender: UITextField) {

        let textFieldValue = sender.text ?? ""
        let isTextFieldEnabled = textFieldValue.count > 0 && textFieldValue != ""

        UIView.animate(withDuration: 0.21,
                       delay: 0,
                       options: .showHideTransitionViews,
                       animations: {
            self.rightButton.alpha = isTextFieldEnabled ? 1 : 0.5
            self.rightButton.isEnabled = isTextFieldEnabled
        })
    }
}

// MARK: - UITextFieldDelegate
extension CustomAlertViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        alertTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.21) {
            self.viewYConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        return true
    }
}
