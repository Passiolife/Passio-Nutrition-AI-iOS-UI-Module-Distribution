//
//  ProgressReoportRanderingView.swift
//  BaseApp
//
//  Created by Mind on 12/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit

protocol ProgressReportRanderingDelegate: NSObjectProtocol{
    func randeringDidCompleted(for view: ProgressReportRanderingView)
}

class ProgressReportRanderingView: ViewFromXIB{
    
    // Launch Objects
    var selectedDateRange: (startDate: Date,endDate: Date)?
    
    
    // Header Outletes
    @IBOutlet private weak var dateRangeLabel: UILabel!
    
    // Profile Outlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dobLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private weak var heightLabel: UILabel!
    @IBOutlet private weak var weigthtLabel: UILabel!
    @IBOutlet private weak var BMILabel: UILabel!
    
    
    //Static Report frame
    class func suggestedFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: 1240, height: 1700)
    }
    
    //Objects or connectors
    let connector = PassioInternalConnector.shared
    weak var delegate: ProgressReportRanderingDelegate?
    
    //Loading states
    var profileDidLoad: Bool = false { didSet { updateProgressReportRendoring() } }
    
    public func setupReport(){
        self.setupAllLoadingStatesFalse()
        self.setupProfile()
    }
    
    private func updateProgressReportRendoring(){
        if self.profileDidLoad{
            self.delegate?.randeringDidCompleted(for: self)
        }
    }
    
    private func setupAllLoadingStatesFalse(){
        profileDidLoad = false
    }
    
    
    private func setupProfile(){
        guard let profile = UserManager.shared.user else { return }
        self.nameLabel.text = (profile.firstName ?? "") + " " + (profile.lastName ?? "")
        self.profileDidLoad = true
    }
    
    
}
