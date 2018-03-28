//
//  NewGameViewController.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/26/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import Foundation
import UIKit


// This class is used for new games
// It creates games from scratch and initializes it with the default parameters
// If the game is modified during the game then it is saved
// Creates dataset entry and edits it if needed
// MVC architecture
class NewGameViewController: UIViewController, ProgressDatasetDelegate, BoardDelegate, BoardControlDelegate {
    
    
    var hasAddedEntry = false
    var board: Board = Board(new: true)
    // Custom delegate
    let delegateID: String = UIDevice.current.identifierForVendor!.uuidString
    
    // Create score
    lazy var scoreItem : UIBarButtonItem = {
        let scoreItem = UIBarButtonItem()
        scoreItem.title = String(board.score)
        return scoreItem
    }()
    
    private var boardView: BoardControl {
        return view as! BoardControl
    }
    
    // Initializer for new games
    init() {
        super.init(nibName: nil, bundle: nil)
        // Set delegates
        ProgressDataset.registerDelegate(self)
        board.delegate = self

        // Bounds for tab
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    // Required
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("board delegate set")
        board.delegate = self
    }
    
    // Loads the view
    override func loadView() {
        
        // Create it
        view = BoardControl()
        
        // Update view
        boardChanged()
        
        // Add entry
        let entry = ProgressDataset.Entry(
            score: board.score,
            cellColors: board.cellColors,
            charPositions: board.charPositions,
            bonusLetters: board.bonusLetters)
        ProgressDataset.appendEntry(entry)
        hasAddedEntry = true
        
        print("Detail view load")
    }
    
    // Load view
    override func viewDidLoad() {
        datasetUpdated()
        
        // Set delegates
        boardView.delegate = self
        board.delegate = self
    }
    
    // Delegates ~~~~~~~~~~~
    
    // Update board
    func boardChanged() {
        // Update table
        self.title = board.currentWord
        scoreItem.title = String(board.score)
        self.navigationItem.rightBarButtonItem = scoreItem
        
        // Update view
        boardView.selectedPositions = board.selectedPositions
        boardView.cellColors = getColor(board.cellColors)
        boardView.charPositions = board.charPositions
        boardView.score = board.score
        boardView.gameWon = lettersLeft() == 0
        
        // Save entry if existing
        let entry = ProgressDataset.Entry(
            score: board.score,
            cellColors: board.cellColors,
            charPositions: board.charPositions,
            bonusLetters: board.bonusLetters)
        
        if (hasAddedEntry) {
            ProgressDataset.editEntry(atIndex: ProgressDataset.count-1, newEntry: entry)
        }
    }
    
    // Dont need
    func datasetUpdated() {}
    
    func cellTouchesBegan(_ pos: CGPoint) {
        print("celltouchedBegan")
        board.beginSelection(pos)
    }
    
    func cellTouchesMoved(_ pos: CGPoint) {
        board.moveSelection(pos)
    }
    
    func cellTouchesEnded() {
        board.resetSelections()
    }
    
    // Helper functions ~~~~~~
    
    // Clear    = 0
    // Green    = 1
    // Red      = 2
    // Black    = 3
    // Yellow   = 4
    // White    = 5
    private func getColor(_ colors: [[String]]) -> [[CGColor]] {
        var newColors: [[CGColor]] = Array(repeatElement(Array(repeatElement(UIColor.clear.cgColor, count: 12)), count: 9))
        // Loop through colors
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
    
    // Helper function to find letters left
    private func lettersLeft() -> Int {
        var num = 0
        for x in 0..<board.charPositions.count {
            for y in 0..<board.charPositions[0].count {
                if (board.charPositions[x][y] != "0" && board.charPositions[x][y] != "1") {
                    num += 1
                }
            }
        }
        return num
    }
    
    // Update order of dataset for tableview
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (lettersLeft() == 0) {
            print("FINISHED GAME")
            let entry = FinishedDataset.Entry(
                score: board.score,
                cellColors: board.cellColors,
                charPositions: board.charPositions,
                bonusLetters: board.bonusLetters)
            FinishedDataset.appendEntry(entry)
            ProgressDataset.deleteEntry(atIndex: FinishedDataset.count-1)
        }
        
        print("View will disappear")
        ProgressDataset.sortData(index: ProgressDataset.count-1)
        FinishedDataset.sortData(index: FinishedDataset.count-1)
        
    }

    
}



