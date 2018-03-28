//
//  ProgressViewController.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/26/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import Foundation
import UIKit

// This view is used for games that are in PROGRESS
// Loads data from the dataset and places it in the game
// MVC architecture
// Game and view talk to viewcontroller, but not each other
class ProgressViewController: UIViewController, ProgressDatasetDelegate, BoardDelegate, BoardControlDelegate {
    
    // Create board object
    // New -> Brand new board
    // Existing -> Progress board
    var board: Board = Board(new: false)
    
    // Position in table
    private let index: Int
    
    // Custom delegate
    let delegateID: String = UIDevice.current.identifierForVendor!.uuidString
    
    // Board view object
    private var boardView: BoardControl {
        return view as! BoardControl
    }
    
    // Create score
    lazy var scoreItem : UIBarButtonItem = {
        let scoreItem = UIBarButtonItem()
        scoreItem.title = String(board.score)
        return scoreItem
    }()
    
    // Initilaizer for existing games
    init(withIndex: Int) {
        // Position in table
        //index = withIndex
        
        ProgressDataset.sortData(index: withIndex)
        //FinishedDataset.sortData(index: FinishedDataset.count-1)
        
        index = 0
        super.init(nibName: nil, bundle: nil)
        
        // Set delegates
        board.delegate = self
        ProgressDataset.registerDelegate(self)
        
        // MAKES IT SO IT DOESNT GO UNDER TAB BARS or NAVIGATION BARS
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    // Required
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set view
    override func loadView() {
        view = BoardControl()
        print("Detail view load")
    }
    
    // Set delegates and update data once view loaded
    override func viewDidLoad() {
        boardView.delegate = self
        datasetUpdated()
    }
    
    // Delegate functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    func cellTouchesBegan(_ pos: CGPoint) {
        board.beginSelection(pos)
    }
    
    func cellTouchesMoved(_ pos: CGPoint) {
        board.moveSelection(pos)
    }
    
    func cellTouchesEnded() {
        board.resetSelections()
    }
    
    // Different than board updated because this is called after its initialized
    // Used to update view and save
    func boardChanged() {
        // Update view
        self.title = board.currentWord
        scoreItem.title = String(board.score)
        self.navigationItem.rightBarButtonItem = scoreItem
        
        boardView.selectedPositions = board.selectedPositions
        boardView.cellColors = getColor(board.cellColors)
        boardView.charPositions = board.charPositions
        boardView.score = board.score
        boardView.gameWon = lettersLeft() == 0
        
        // Edit entry
        let entry = ProgressDataset.Entry(
            score: board.score,
            cellColors: board.cellColors,
            charPositions: board.charPositions,
            bonusLetters: board.bonusLetters)
        ProgressDataset.editEntry(atIndex: index, newEntry: entry)
    }
    
    // Function updates all needed data
    // Function called when initializing
    func datasetUpdated() {
        // Get entry
        let entry = ProgressDataset.entry(atIndex: index)
        
        // Update data
        board.cellColors = entry.cellColors
        board.charPositions = entry.charPositions
        board.score = entry.score
        board.bonusLetters = entry.bonusLetters
        
        // Set current word
        self.title = board.currentWord
        
        // Update score
        scoreItem.title = String(board.score)
        // Set score
        self.navigationItem.rightBarButtonItem = scoreItem
        
        // Set view
        boardView.selectedPositions = board.selectedPositions
        boardView.cellColors = getColor(board.cellColors)
        boardView.charPositions = board.charPositions
        boardView.score = board.score
        boardView.gameWon = lettersLeft() == 0
    }
    
    // Delegate Functions end ~~~~~~~~~~
    
    // Clear    = 0
    // Green    = 1
    // Red      = 2
    // Black    = 3
    // Yellow   = 4
    // White    = 5
    // Helper function to transfer data from game to view
    // Game data is in number format
    // View data is in CGCOLOR
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
        print(board.charactersLeft)
        if (lettersLeft() == 0) {
            print("FINISHED GAME")
            let entry = FinishedDataset.Entry(
                score: board.score,
                cellColors: board.cellColors,
                charPositions: board.charPositions,
                bonusLetters: board.bonusLetters)
            FinishedDataset.appendEntry(entry)
            ProgressDataset.deleteEntry(atIndex: index)
        }
        
        print("View will disappear")
        ProgressDataset.sortData(index: index)
        FinishedDataset.sortData(index: FinishedDataset.count-1)
        
    }
}

