//
//  ReceivedTextTableViewCell.swift
//  BaseApp
//
//  Created by Mind on 24/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
import SwiftyMarkdown

class ReceivedTextTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!

    func setup(datasource: NutritionAdvisorMessageDataSource) {

        let advisorResponse = datasource.response

        if let extractedIngredients = advisorResponse?.extractedIngredients?.first {
            messageLabel.text = """
                                • Name: \(extractedIngredients.recognisedName.capitalized)
                                • Portion: \(extractedIngredients.portionSize)
                                • WeightGrams: \(extractedIngredients.weightGrams)
                            """
        } else {
            let markupString = advisorResponse?.markupContent.trimmingCharacters(in: .whitespacesAndNewlines)
            var md = SwiftyMarkdown(string: markupString ?? "")
            setupMD(md: &md)
            messageLabel.attributedText = md.attributedString()
        }
    }

    func setupMD(md: inout SwiftyMarkdown) {

        md.setFontNameForAllStyles(with: UIFont.inter(type: .regular).familyName)
        md.setFontSizeForAllStyles(with: 14)
        md.setFontColorForAllStyles(with: .white)

        md.h1.fontName =  UIFont.inter(type: .semiBold).fontName
        md.h2.fontName =  UIFont.inter(type: .semiBold).fontName
        md.h3.fontName =  UIFont.inter(type: .semiBold).fontName
        md.h4.fontName =  UIFont.inter(type: .semiBold).fontName
        md.h5.fontName =  UIFont.inter(type: .semiBold).fontName
        md.h6.fontName =  UIFont.inter(type: .semiBold).fontName
        md.body.fontName = UIFont.inter(type: .regular).fontName
        md.bold.fontName = UIFont.inter(type: .bold).fontName

        md.h1.fontSize = 24
        md.h2.fontSize = 22
        md.h3.fontSize = 20
        md.h4.fontSize = 18
        md.h5.fontSize = 16
        md.h6.fontSize = 14
        md.body.fontSize = 14
        md.bold.fontSize = 14
    }
}
