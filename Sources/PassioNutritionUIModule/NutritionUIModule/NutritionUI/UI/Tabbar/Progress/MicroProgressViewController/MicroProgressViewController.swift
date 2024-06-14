//
//  MicroProgressViewController.swift
//  BaseApp
//
//  Created by Mind on 29/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit

class MicroProgressViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var nextDateButton: UIButton!
    @IBOutlet weak var informationCardContainerView: UIView!
    @IBOutlet weak var iButton: UIButton!

    lazy var footerButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: ScreenSize.width, height: 40))
        button.setTitle("See more", for: .normal)
        button.setTitleColor(.indigo600, for: .normal)
        button.setTitle("See less", for: .selected)
        button.setTitleColor(.indigo600, for: .selected)
        button.titleLabel?.font = UIFont.inter(type: .medium, size: 15)
        button.addTarget(self, action: #selector(onClickSeeMore), for: .touchUpInside)
        return button
    }()



    let connector = PassioInternalConnector.shared
    var dateSelector: DateSelectorViewController?

    enum CellType: Int{
        case nutrition,calender,waterweight
    }

    let cells: [CellType] = [.nutrition,.calender]

    var selectedDate: Date = Date(){
        didSet {
            self.setDateTitle()
            self.getRecords(for: selectedDate)
            if self.selectedDate.isToday{
                self.nextDateButton.isEnabled = false
            }else{
                self.nextDateButton.isEnabled = true
            }
        }
    }

    private var microNutrients = [MicroNutirents]() {
        didSet {
            self.tableView.reloadData()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedDate = Date()
        self.registerCell()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.onClickIIcon()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setDateTitle()
        self.getRecords(for: selectedDate)
        self.tableView.reloadData()
    }

    func registerCell(){
        tableView.register(nibName: "MicroNutrientsInfoCell")
        self.tableView.tableFooterView = footerButton
    }

    func setupTableView(){

    }

    @IBAction func onClickIIcon(){
        self.iButton.isHidden = true
        self.informationCardContainerView.isHidden = false
    }

    @IBAction func onClickCross(){
        self.iButton.isHidden = false
        self.informationCardContainerView.isHidden = true
    }

    @objc func onClickSeeMore(){
        footerButton.isSelected = !footerButton.isSelected
        self.tableView.reloadData()
    }


    @IBAction func onNextPrevButtonPressed(_ sender: UIButton) {
        let nextDate = Calendar.current.date(byAdding: .day, value: sender.tag == 1 ? 1 : -1, to: selectedDate)!
        self.selectedDate = nextDate
    }

    func setDateTitle(){
        if selectedDate.isToday{
            dateButton.setTitle("Today".localized, for: .normal)
        }else{
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
            let newTitle = dateFormatterPrint.string(for: selectedDate)
            dateButton.setTitle(newTitle, for: .normal)
        }
    }


}

// MARK: - Daylog -
extension MicroProgressViewController{
    func getRecords(for date: Date?){
        guard let date = date else { return }
        connector.fetchDayRecords(date: date) {[weak self] (foodRecords) in
            guard let `self` = self else { return }
            self.microNutrients = MicroNutirents.getMicroNutrientsFromFood(records: foodRecords)
        }
    }
}

extension MicroProgressViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let visibleRowNumbers = 10
        //Saturated Fat,Trans Fat,Cholesterol,Sodium,Dietary Fiber,Total Sugars,Vitamin D,Calcium,Iron,Potassium
        if microNutrients.count > visibleRowNumbers{
            return self.footerButton.isSelected ? microNutrients.count : visibleRowNumbers
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

// MARK: - DateSelection
extension MicroProgressViewController: DateSelectorUIViewDelegate{


    @IBAction func showDateSelector(_ sender: Any) {
        dateSelector = DateSelectorViewController()
        dateSelector?.delegate = self
        dateSelector?.modalPresentationStyle = .overFullScreen
        self.parent?.present(dateSelector!, animated: false)
    }


    func removeDateSelector(remove: Bool) {
        dateSelector?.dismiss(animated: false)
    }

    func dateFromPicker(date: Date) {
        self.selectedDate = date
    }

}

