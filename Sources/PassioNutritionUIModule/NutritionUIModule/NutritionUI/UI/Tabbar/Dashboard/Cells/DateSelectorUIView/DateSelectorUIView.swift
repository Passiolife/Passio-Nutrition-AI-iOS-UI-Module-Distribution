//
//  DateSelectorUIView.swift
//  Passio App Module
//
//  Created by zvika on 2/13/19.
//  Copyright © 2022 Passiolife Inc. All rights reserved.
//

import UIKit

protocol DateSelectorUIViewDelegate: AnyObject {
    func dateFromPicker(date: Date)
    func removeDateSelector(remove: Bool)
}

final class DateSelectorViewController: UIViewController {

    weak var delegate: DateSelectorUIViewDelegate?
    var dateSelector: DateSelectorUIView!
    var dateForPicker: Date?

    enum SelectorDirections {
        case down, upWards
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .gray500
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showDateSelector()
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.animateDateSelector(directions: .upWards)
    }

    func showDateSelector() {
        if dateSelector == nil {
            let screenWidth = ScreenSize.width
            let frameStart = CGRect(x: 0, y: -screenWidth, width: screenWidth, height: screenWidth)
            dateSelector = DateSelectorUIView.init(frame: frameStart, date: Date())
            dateSelector.dateForPicker = dateForPicker ?? Date()

            dateSelector?.frame = frameStart
            dateSelector?.delegate = self.delegate
            self.dateSelector?.roundMyCornerWith(radius: 20)
            view.addSubview(dateSelector!)
            animateDateSelector(directions: .down)
        } else {
            animateDateSelector(directions: .upWards)
        }
    }

    func animateDateSelector(directions: SelectorDirections) {

        let screenWidth = ScreenSize.width
        let y = directions == .down ? 0 : -screenWidth
        let frameEnd = CGRect(x: 0, y: y, width: screenWidth, height: screenWidth)
        
        UIView.animate(withDuration: 0.41,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
            self.dateSelector?.frame = frameEnd
        },
                       completion: { _ in
            if directions == .upWards {
                self.dateSelector = nil
                super.dismiss(animated: false)
            }
        })
    }
}

// MARK: - DateSelectorUIView
final class DateSelectorUIView: ViewFromXIB {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonToday: UIButton!
    @IBOutlet weak var buttonOK: UIButton!

    var dateForPicker: Date?
    weak var delegate: DateSelectorUIViewDelegate?

    public init(frame: CGRect, date: Date) {
        super.init(frame: frame)
        dateForPicker = date
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // containerView.roundMyCornerWith(radius: 17, upper: false, down: true)
    }

    override func layoutSubviews() {
        if let date = dateForPicker {
            datePicker?.date = date
        }
        datePicker?.preferredDatePickerStyle = .wheels
        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
        datePicker.setValue(false, forKeyPath: "highlightsToday")
        datePicker.overrideUserInterfaceStyle = .dark
        datePicker.addTarget(self, action: #selector(reportValue), for: .valueChanged)
        datePicker.maximumDate = Date()
    }

    @IBAction func okAndDismiss(_ sender: UIButton) {
        delegate?.dateFromPicker(date: datePicker.date)
        delegate?.removeDateSelector(remove: true)
    }

    @IBAction func todayAndDismiss(_ sender: UIButton) {
        datePicker.setDate(Date(), animated: true)
        delegate?.dateFromPicker(date: Date())
        perform(#selector(removeMe), with: nil, afterDelay: 0.4)
    }

    @objc private func reportValue() {
        // delegate?.dateFromPicker(date: datePicker.date)
    }

    @objc private func removeMe() {
        delegate?.removeDateSelector(remove: true)
    }
}
