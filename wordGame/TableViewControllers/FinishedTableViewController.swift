//
//
//  Created by Caelan Dailey on 2/20/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//
// Represents the data set of finished games
// Just display the score of each game
// Displays the most recent finished game first

import UIKit

class FinishedTableViewController: UITableViewController, FinishedDatasetDelegate {
    
    private static var cellReuseIdentifier = "FinishedTableViewController.DatasetItemsCellIdentifier"
    
    let delegateID: String = UIDevice.current.identifierForVendor!.uuidString
    
    // Update on main thread
    func datasetUpdated() {
        DispatchQueue.main.async(){
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        datasetUpdated()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FinishedDataset.registerDelegate(self)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FinishedTableViewController.cellReuseIdentifier)
        //self.navigationItem.rightBarButtonItem = createAlarmButton
        self.navigationItem.leftBarButtonItem = refreshListButton
        self.title = "Finished"
    }
    
    // Refresh table if buggy
    lazy var refreshListButton : UIBarButtonItem = {
        let refreshListButton = UIBarButtonItem()
        refreshListButton.image = UIImage(named: "refresh_icon")
        refreshListButton.action = #selector(updateTable)
        refreshListButton.target = self
        refreshListButton.style = .plain
        return refreshListButton
    }()
    
    @objc func updateTable(sender: UIButton) {
        datasetUpdated()
    }
    
    // Go to new alarm
    @objc func goToAlarmView(sender: UIBarButtonItem) {
        
        navigationController?.pushViewController(NewGameViewController(), animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView == self.tableView, section == 0 else {
            return 0
        }
        
        return FinishedDataset.count
    }

    // THIS CREATES THE CELLS
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView === self.tableView, indexPath.section == 0, indexPath.row < FinishedDataset.count else {
            return UITableViewCell()
        }
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: FinishedTableViewController.cellReuseIdentifier, for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: FinishedTableViewController.cellReuseIdentifier)
        }
        
        // Just show score
        let game = FinishedDataset.entry(atIndex: indexPath.row)
        cell.textLabel?.text = "Score: " + String(game.score)
        
        return cell
    }
    
    // Allows editing
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    // If we can edit then check editing style
    // THIS WORKS ON ALARMTABLE BUT NOT EVENT TABLE
    // WHY?
    override func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // if deleting
        if (editingStyle == .delete) {
            // delete entry
            FinishedDataset.deleteEntry(atIndex: indexPath.row)
            // Update table
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
        }
    }
    
    // GO TO GAME
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView === self.tableView, indexPath.section == 0, indexPath.row < FinishedDataset.count else {
            return
        }
        navigationController?.pushViewController(FinishedViewController(withIndex: indexPath.row), animated: true)
    }
}
