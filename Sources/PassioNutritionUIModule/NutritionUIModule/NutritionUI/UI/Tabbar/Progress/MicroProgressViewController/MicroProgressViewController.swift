//
//  MicroProgressViewController.swift
//  BaseApp
//
//  Created by Mind on 29/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class MicroProgressViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var nextDateButton: UIButton!
    @IBOutlet weak var informationCardContainerView: UIView!
    @IBOutlet weak var iButton: UIButton!

    lazy var footerButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: ScreenSize.width, height: 40))
        button.setTitle("See more", for: .normal)
        button.setTitleColor(.primaryColor, for: .normal)
        button.setTitle("See less", for: .selected)
        button.setTitleColor(.primaryColor, for: .selected)
        button.titleLabel?.font = UIFont.inter(type: .medium, size: 15)
        button.addTarget(self, action: #selector(onClickSeeMore), for: .touchUpInside)
        return button
    }()

    private let connector = PassioInternalConnector.shared
    private var dateSelector: DateSelectorViewController?

    private var selectedDate: Date = Date() {
        didSet {
            setDateTitle()
            getRecords(for: selectedDate)
            nextDateButton.isEnabled = selectedDate.isToday ? false : true
        }
    }
    private var microNutrients = [MicroNutirents]() {
        didSet {
            tableView.reloadData()
        }
    }

    enum CellType: Int {
        case nutrition, calender, waterweight
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDate = Date()
        registerCell()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        onClickIIcon()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setDateTitle()
        getRecords(for: selectedDate)
        tableView.reloadData()
    }

    func registerCell() {
        tableView.register(nibName: MicroNutrientsInfoCell.className)
        tableView.tableFooterView = footerButton
    }

    @IBAction func onClickIIcon() {
        iButton.isHidden = true
        informationCardContainerView.isHidden = false
    }

    @IBAction func onClickCross() {
        iButton.isHidden = false
        informationCardContainerView.isHidden = true
    }

    @objc func onClickSeeMore() {
        footerButton.isSelected = !footerButton.isSelected
        tableView.reloadData()
    }

    @IBAction func onNextPrevButtonPressed(_ sender: UIButton) {
        let nextDate = Calendar.current.date(byAdding: .day,
                                             value: sender.tag == 1 ? 1 : -1,
                                             to: selectedDate)!
        selectedDate = nextDate
    }

    func setDateTitle() {
        if selectedDate.isToday {
            dateButton.setTitle("Today".localized, for: .normal)
        } else {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
            let newTitle = dateFormatterPrint.string(for: selectedDate)
            dateButton.setTitle(newTitle, for: .normal)
        }
    }

    func getRecords(for date: Date?) {
        guard let date = date else { return }
        connector.fetchDayRecords(date: date) { [weak self] (foodRecords) in
            guard let self else { return }
            microNutrients = MicroNutirents.getMicroNutrientsFromFood(records: foodRecords)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension MicroProgressViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let visibleRowNumbers = 10
        if microNutrients.count > visibleRowNumbers {
            return footerButton.isSelected ? microNutrients.count : visibleRowNumbers
        }
        return microNutrients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(cellClass: MicroNutrientsInfoCell.self, forIndexPath: indexPath)
        let microNutrient = microNutrients[indexPath.row]
        cell.configureCell(name: microNutrient.name,
                           value: microNutrient.value,
                           unit: microNutrient.unit,
                           recommendedValue: microNutrient.recommendedValue)
        return cell
    }
}

// MARK: - DateSelectorUIView Delegate
extension MicroProgressViewController: DateSelectorUIViewDelegate {

    @IBAction func showDateSelector(_ sender: Any) {
        dateSelector = DateSelectorViewController()
        dateSelector?.delegate = self
        dateSelector?.modalPresentationStyle = .overFullScreen
        parent?.present(dateSelector!, animated: false)
    }

    func removeDateSelector(remove: Bool) {
        dateSelector?.dismiss(animated: false)
    }

    func dateFromPicker(date: Date) {
        selectedDate = date
    }
}
