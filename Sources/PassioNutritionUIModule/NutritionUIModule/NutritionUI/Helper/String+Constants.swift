//
//  String+Constants.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 24/02/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import Foundation

// MARK: - TableView Cell's Name
enum CellName {
    static let segmentedCell = "SegmentedTableViewCell"
    static let microNutrientsInfoCell = "MicroNutrientsInfoCell"
    static let quickLogSuggestionsCell = "QuickLogSuggestionsCell"
    static let barChartsCell = "BarChartsCell"
    static let mealPlanCell = "MealPlanCell"
    static let textSearchTableViewCell = "TextSearchTableViewCell"
    static let alternativesFlatCollectionViewCell = "AlternativesFlatCollectionViewCell"
}

// MARK: - DateFormat String
enum DateFormatString {
    static let EEEE_MMM_dd_yyyy = "EEEE MMM dd yyyy"
    static let MMMM_yyyy = "MMMM - yyyy"
    static let yyyy_MM_dd = "yyyy/MM/dd"
    static let h_mm_a = "h:mm a"
    static let HH_mm = "HH.mm"
    static let HHmm = "HH:mm"
    static let MM_dd_yyyy_E = "MM/dd/yyyy | E"
    static let M_d_yyyy = "M-d-yyyy"
    static let M_d_yyyy2 = "M/d/yyyy"
    static let yyyyMMdd = "yyyyMMdd"
    static let EEEMMMddYYYYhmma = "EEE, MMM dd YYYY, h:mm a"
}

// MARK: - Image's Name
enum ImageName {
    static let naiyaLogo = "ic_NaiyaLogo"
    static let bgImage = "bgImage"
    static let ellipsisMenu = "ellipsis.circle"
    static let settingsGear = "gear"
    static let reminder = "alarm"
    static let close = "close"
    static let chevUp = "chevron.up"
    static let chevRight = "chevron.right"
    static let chevDown = "chevron.down"
    static let person = "person.fill"
    static let password = "lock.fill"
    static let radioSelect = "radio_select"
    static let radioUnseled = "radio_false"
    static let tutorial1 = "tutorial1"
    static let tutorial2 = "tutorial2"
    static let tutorial3 = "tutorial3"
    static let tutorial4 = "tutorial4"
    static let progressReport = "progress_report"
    static let tutorialBook = "book.fill"
    static let delete = "trash.fill"
    static let pencil = "pencil"
    static let circle_fill = "circle.fill"
    static let circle = "circle"
    static let spinnerCircles = "spinner_circles"
    static let weightEsti = "weight_estimation"
    static let startRecording = "record.circle.fill"
    static let stopRecording = "stop.circle.fill"
    static let camera = "camera.circle.fill"
    static let trial = "graduationcap"
}

// MARK: - Storyboard's Name
enum StoryboardName {
    static let welcome = "Welcome"
    static let home = "Home"
    static let setup = "Setup"
}

// MARK: - ViewController's ID
enum ViewControllerID {
    static let trialOrCode = "TrialOrCodeViewController"
    static let acceptTerms = "AcceptTermsViewController"
    static let verify = "VerifyClientCodeViewController"
    static let login = "LoginNavID"
    static let signUp = "navSignUpID"
    static let setup = "SetupStoryboard"
    static let homeTabBar = "HomeTabBarVC"
    static let deactivated = "DeactivatedViewController"
    static let trialOver = "TrialOverViewController"
}

enum PrivacyTOSURLS {
    static let privacyPolicy = "https://www.naiya.app/privacy"
    static let termsOfService = "https://www.naiya.app/terms-of-use"
}
