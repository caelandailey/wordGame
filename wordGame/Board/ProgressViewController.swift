//
//  ProgressViewController.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/26/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import Foundation
import UIKit

import UIKit

class ProgressViewController: UIViewController, AlarmDatasetDelegate, BoardDelegate, BoardControlDelegate {
    
    var board: Board = Board()
    
    private let index: Int
    
    /*
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        board.delegate = self
    }
    */
    // Custom delegate
    let delegateID: String = UIDevice.current.identifierForVendor!.uuidString
    
    private var boardView: BoardControl {
        return view as! BoardControl
    }
    
    func datasetUpdated() {
        /*
        let entry = AlarmDataset.entry(atIndex: index)
        alarmView.alarmName = entry.name
        alarmView.alarmTime = entry.time
        alarmView.alarmDuration = entry.duration
        alarmView.currentDays = entry.days
        alarmView.currentRepeater = entry.repeater
        alarmView.currentZone = entry.zone
 */
    }
    
    init(withIndex: Int) {
        index = withIndex
        super.init(nibName: nil, bundle: nil)
        board.delegate = self
        AlarmDataset.registerDelegate(self)
        // MAKES IT SO IT DOESNT GO UNDER TAB BARS or NAVIGATION BARS
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = BoardControl()
        print("Detail view load")
    }
    override func viewDidLoad() {
        datasetUpdated()
        boardView.delegate = self
    }
    
    func cellTouchesBegan(_ pos: CGPoint) {
        
    }
    
    func cellTouchesMoved(_ pos: CGPoint) {
        
    }
    
    func cellTouchesEnded(_ pos: CGPoint) {
        
    }
    
    func boardChanged() {
        
    }
    
    // We left the edit view so save everything that we edited!!
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("edit alarm viewDidDisappear")
        
        /*
        let entry = AlarmDataset.Entry(
            name: alarmView.alarmName,
            days: alarmView.currentDays,
            repeater: alarmView.currentRepeater,
            zone: alarmView.currentZone,
            duration: alarmView.alarmDuration,
            time: alarmView.alarmTime
        )
        AlarmDataset.editEntry(atIndex: index, newEntry: entry)
 */
    }
}

