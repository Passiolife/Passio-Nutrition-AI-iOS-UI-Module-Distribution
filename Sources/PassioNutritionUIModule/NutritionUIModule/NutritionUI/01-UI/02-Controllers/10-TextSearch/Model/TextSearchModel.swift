//
//  TextSearchModel.swift
//
//
//  Created by Nikunj Prajapati on 16/09/24.
//

import UIKit

enum SearchState: Equatable {

    case noResult(text: String)
    case startTyping
    case typing
    case searching
    case searched

    func getSFSymbolImage(name: String) -> UIImage? {
        UIImage(systemName: name)?.applyingSymbolConfiguration(.init(pointSize: 28,
                                                                     weight: .regular,
                                                                     scale: .small))
    }

    var image: UIImage? {
        switch self {
        case .noResult:
            return getSFSymbolImage(name: "nosign")
        case .typing:
            return getSFSymbolImage(name: "rectangle.and.pencil.and.ellipsis")
        case .searching:
            return getSFSymbolImage(name: "text.magnifyingglass")
        case .searched:
            return nil
        case .startTyping:
            return getSFSymbolImage(name: "pencil")
        }
    }

    var message: String? {
        switch self {
        case .noResult(let text):
            return text + " is not in the database".localized
        case .typing:
            return "Keep typing"
        case .searching:
            return "Searching"
        case .searched:
            return nil
        case .startTyping:
            return "Start typing"
        }
    }
}

enum SearchViewSections {
    case alternateSearchNames
    case searchResults
    case searchStatus
    case customFoods
}
