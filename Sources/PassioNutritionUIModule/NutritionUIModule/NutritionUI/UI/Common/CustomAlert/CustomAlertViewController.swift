//
//  CustomAlertViewController.swift
//
//
//  Created by Nikunj Prajapati on 19/06/24.
//

import UIKit

protocol CustomAlertDelegate: AnyObject {
    func onRightButtonTapped()
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
}

class CustomAlertViewController: InstantiableViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alertTextField: UITextField!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!

    weak var delegate: CustomAlertDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white.withAlphaComponent(0.5)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        contentView.dropShadow(radius: 8,
                               offset: .init(width: 1, height: 1),
                               color: .black.withAlphaComponent(0.3),
                               shadowRadius: 4,
                               shadowOpacity: 1,
                               useShadowPath: true)
    }

    func configureAlert(views: CustomAlert = CustomAlert()) {
        headingLabel.isHidden = views.headingLabel
        titleLabel.isHidden = views.titleLabel
        alertTextField.isHidden = views.alertTextField
        rightButton.isHidden = views.rightButton
        leftButton.isHidden = views.leftButton
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
        // alertTextField.attributedPlaceholder = font.textFieldPlaceholderFont
        rightButton.titleLabel?.font = font.rightButtonFont
        leftButton.titleLabel?.font = font.leftButtonFont
    }

    @IBAction func onRightButton(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.onRightButtonTapped()
        }
    }

    @IBAction func onLeftButton(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.onleftButtonTapped()
        }
    }
}
