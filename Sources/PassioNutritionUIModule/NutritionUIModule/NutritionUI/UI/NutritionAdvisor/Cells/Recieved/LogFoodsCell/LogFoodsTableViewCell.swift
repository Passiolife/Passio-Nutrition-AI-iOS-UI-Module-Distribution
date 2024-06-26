//
//  LogFoodsTableViewCell.swift
//  
//
//  Created by Davido Hyer on 6/24/24.
//

import UIKit

class LogFoodsTableViewCell: UITableViewCell {
    @IBOutlet weak var itemTable: UITableView!
    @IBOutlet weak var logButton: UIButton!

    private var items = [PassioAdvisorFoodInfo]()
    
    func setup(items: [PassioAdvisorFoodInfo]) {
        self.items = items
        itemTable.reloadData()
    }
    
    @IBAction func logFoods() {
        
    }
}

extension LogFoodsTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        
    }
    
    
}

extension LogFoodsTableViewCell: UITableViewDelegate {
    
}
