//

//
//  Created by Caelan Dailey on 2/20/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//
// This class represents the list of games in progress in our progressdataset in TABLE form
// Game can have a list of colors, list of characters, score, bonus letters
// Table shows preview of game that shows the blocks that are left
// Can add games or go to games in progress from this table or just view games in progress

import UIKit

class ProgressTableViewController: UITableViewController, ProgressDatasetDelegate {
    
    private static var cellReuseIdentifier = "ProgressTableViewController.DatasetItemsCellIdentifier"
    
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
        ProgressDataset.registerDelegate(self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ProgressTableViewController.cellReuseIdentifier)
        self.navigationItem.rightBarButtonItem = newGameButton
        self.navigationItem.leftBarButtonItem = refreshListButton
        self.title = "In-progress"
    }
    
    // Create button
    lazy var newGameButton : UIBarButtonItem = {
        let newGameButton = UIBarButtonItem()
        newGameButton.title = "+"
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        var styles: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): style]
        styles[NSAttributedStringKey.font] = UIFont(name: "DINCondensed-Bold", size: 40 )
        
        // set string
        let zone:String = "Days"
        
        // Create and draw
        newGameButton.setTitleTextAttributes(styles, for: UIControlState.normal)
        newGameButton.action = #selector(goToAlarmView)
        newGameButton.target = self
        return newGameButton
    }()
    
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
        
        return ProgressDataset.count
    }
    // Clear    = 0
    // Green    = 1
    // Red      = 2
    // Black    = 3
    // Yellow   = 4
    // White    = 5
    // Helper function to get colors
    private func getColor(_ colors: [[String]]) -> [[CGColor]] {
        var newColors: [[CGColor]] = Array(repeatElement(Array(repeatElement(UIColor.clear.cgColor, count: 12)), count: 9))
        for y in 0..<colors[0].count {
            for x in 0..<colors.count {
                switch colors[x][y] {
                case "0": newColors[x][y] = UIColor.clear.cgColor
                case "1": newColors[x][y] = UIColor.green.cgColor
                case "2": newColors[x][y] = UIColor.red.cgColor
                case "3": newColors[x][y] = UIColor.black.cgColor
                case "4": newColors[x][y] = UIColor.yellow.cgColor
                case "5": newColors[x][y] = UIColor.white.cgColor
                default: newColors[x][y] = UIColor.clear.cgColor
                }
            }
        }
        return newColors
    }
    
    // Calculates the letters that are left
    private func lettersLeft(_ letters: [[String]]) -> CGFloat {
        var num: CGFloat = 0
        for x in 0..<letters.count {
            for y in 0..<letters[0].count {
                if (letters[x][y] != "0") {
                    num += 1
                }
            }
        }
        return num
    }

    // THIS CREATES THE CELLS
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView === self.tableView, indexPath.section == 0, indexPath.row < ProgressDataset.count else {
            return UITableViewCell()
        }
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ProgressTableViewController.cellReuseIdentifier, for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: ProgressTableViewController.cellReuseIdentifier)
        }
        cell.backgroundColor = UIColor.groupTableViewBackground
        
        //Add text
        let game = ProgressDataset.entry(atIndex: indexPath.row)
        let complete = Int(100 * (lettersLeft(game.charPositions)/108))
        cell.textLabel?.text = "Score: " + String(game.score) + " | Percentage %: \(complete)"
        
        // Add preview
        let gamePreview = GamePreview()
        gamePreview.frame = CGRect(x: 5, y: 0, width: 30, height: 40)
        gamePreview.cellColors = getColor(game.cellColors)
        gamePreview.backgroundColor = UIColor.clear
        
        cell.accessoryView = gamePreview
 
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
            ProgressDataset.deleteEntry(atIndex: indexPath.row)
            // Update table
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
        }
    }
    
    // GO TO EDIT
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView === self.tableView, indexPath.section == 0, indexPath.row < ProgressDataset.count else {
            return
        }
        navigationController?.pushViewController(ProgressViewController(withIndex: indexPath.row), animated: true)
    }
}

