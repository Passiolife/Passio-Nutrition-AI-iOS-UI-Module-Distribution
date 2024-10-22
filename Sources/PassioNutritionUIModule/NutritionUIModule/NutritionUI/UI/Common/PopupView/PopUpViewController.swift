//
//  PopUpViewController.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 27/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
import SafariServices

final class PopUpViewController: InstantiableViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var okButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        infoTextView.delegate = self
        infoTextView.addHyperLinksToText(originalText: "The nutrition information provided can be found from Open Food Facts, Which is made available under the Open Database License.",
                                         hyperLinks: ["Open Food Facts": "https://en.openfoodfacts.org/",
                                                      "Open Database License.": "https://opendatacommons.org/licenses/odbl/1-0"],
                                         textColor: .gray900,
                                         linkColor: .primaryColor)
    }

    @IBAction func onOkAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension PopUpViewController: UITextViewDelegate {

    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {

        let safari = SFSafariViewController(url: URL)
        safari.modalPresentationStyle = .formSheet
        present(safari, animated: true, completion: nil)
        return false
    }
}
