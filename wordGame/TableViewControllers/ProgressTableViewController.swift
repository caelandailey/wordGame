//
//  TableViewController.swift
//  Elephant
//
//  Created by Caelan Dailey on 2/20/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//
// This class represents the list of alarms in our alarmdataset in TABLE form
// alarm can have a name, date, ect
// Table can edit alarms
// Table can delete alarms
// Table can refresh
// Table can add alarms

import UIKit

class ProgressTableViewController: UITableViewController, AlarmDatasetDelegate {
    
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
        AlarmDataset.registerDelegate(self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ProgressTableViewController.cellReuseIdentifier)
        self.navigationItem.rightBarButtonItem = createAlarmButton
        self.navigationItem.leftBarButtonItem = refreshListButton
        self.title = "In-progress"
    }
    
    // Create button
    lazy var createAlarmButton : UIBarButtonItem = {
        let createAlarmButton = UIBarButtonItem()
        createAlarmButton.title = "+"
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        var styles: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): style]
        styles[NSAttributedStringKey.font] = UIFont(name: "DINCondensed-Bold", size: 40 )
        
        // set string
        let zone:String = "Days"
        
        // Create and draw
        createAlarmButton.setTitleTextAttributes(styles, for: UIControlState.normal)
        createAlarmButton.action = #selector(goToAlarmView)
        createAlarmButton.target = self
        return createAlarmButton
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
        
        return AlarmDataset.count
    }
    
    // THIS CREATES THE CELLS
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView === self.tableView, indexPath.section == 0, indexPath.row < AlarmDataset.count else {
            return UITableViewCell()
        }
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ProgressTableViewController.cellReuseIdentifier, for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: ProgressTableViewController.cellReuseIdentifier)
        }
        
        // 
        
        
        
        // Get obj for row
        let alarm = AlarmDataset.entry(atIndex: indexPath.row)
        cell.textLabel?.text = alarm.name
        
        // Create labels
        // Not complicatec
        let hour: Int = Int(alarm.time/3600)
        let minute: Int = (Int(alarm.time) - (hour)*3600) / 60
        var minuteString = String(minute)
        if (minute < 10) {
            minuteString = "0\(minute)"
        }
        var dayString = ""
        for i in 0...6 {
            if (alarm.days[i] == 1) {
                
                switch(i) {
                case 0: dayString += " Mon"
                case 1: dayString += " Tue"
                case 2: dayString += " Wed"
                case 3: dayString += " Thu"
                case 4: dayString += " Fri"
                case 5: dayString += " Sat"
                case 6: dayString += " Sun"
                default: dayString += ""
                }
            }
        }
        var textString = dayString + " \(hour):" + minuteString + " Repeating: "
        textString += "\(alarm.repeater)"
        textString += " Duration: \(Int(alarm.duration))"
        cell.detailTextLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = textString
        
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
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
            AlarmDataset.deleteEntry(atIndex: indexPath.row)
            // Update table
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
        }
    }
    
    // GO TO EDIT ALARM
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView === self.tableView, indexPath.section == 0, indexPath.row < AlarmDataset.count else {
            return
        }
        
        navigationController?.pushViewController(ProgressViewController(withIndex: indexPath.row), animated: true)
        
    }
    
}

