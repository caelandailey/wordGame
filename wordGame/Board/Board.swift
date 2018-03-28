//
//  Board.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/25/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import Foundation
import UIKit

// Delegate protocol

protocol BoardDelegate: AnyObject {
    func boardChanged()
}

// Represents the game
// Does all the work that the game needs to do such as calculating cell colors
// Calculates which cells are deleted
// Calculates which words to use and where to place them
// Caclulates how to delete, etc

class Board {
    
    weak var delegate: BoardDelegate? = nil
    
    // Used for calculations
    private var currentPosition = CGPoint(x: 0, y: 0)
    private var words: [String] = []
    private var validWords: [String] = []
    
    // Used to represent the game
    var bonusLetters = Array(repeatElement(Array(repeatElement("0", count: 12)), count: 9))
    var cellColors = Array(repeatElement(Array(repeatElement("0", count: 12)), count: 9))
    var charPositions = Array(repeatElement(Array(repeatElement("0", count: 12)), count: 9))
    var selectedPositions = [CGPoint]()
    
    // Bonus information
    var charactersLeft = 94
    private var blanksLeft = 10
    private var bonusLettersLeft = 4
    var currentWord = ""
    var score = 0
    
    // Creates the game, if it's new do extra initialization
    init(new: Bool) {
        getValidWords()
        
        // THis creates new words and placements of letters and bonus and blanks
        if (new) {
        placeBlanks()
        placeWords()
        setBonusLetters()
        }
        
        updateColors()
    }
    
    // Called when released tap
    func resetSelections() {
        
        // Only delete if
        if (selectedPositions.count > 1 && currentWordIsValid()) {
            deleteWord()
        }
        
        // Clear
        selectedPositions.removeAll()
        currentWord = ""
    
        // Update view
        updateColors()
    }
    
    // Called if tap moved
    func moveSelection(_ pos: CGPoint) {
        
        let xPos = Int(pos.x)
        let yPos = Int(pos.y)
        
        let position = pos
        
        
        // If not valid return
        if (charPositions[xPos][yPos] == "0" || charPositions[xPos][yPos] == "1") {
            return
        }
        
        // CHeck if close or not.If far away its WRONG
        var isNotClose = true
        
        for square in selectedPositions {
            if abs(Int(square.x) - xPos) < 2 && abs(Int(square.y) - yPos) < 2 {
                isNotClose = false
            }
        }
        if (isNotClose) {
            return
        }
        
        // Checks to see if valid
        
        if (!selectedPositions.contains(position)) {    // If not position
            selectedPositions.append(position)
            currentPosition = position
            currentWord += charPositions[xPos][yPos]

        } else {   // If going backwards erase
            let count = selectedPositions.count
            if (count > 1) {
                if (selectedPositions[count-2] == position) {
                    selectedPositions.removeLast()
                    let endIndex = currentWord.index(currentWord.endIndex, offsetBy: -1)
                    currentWord = String(currentWord[..<endIndex])
                }
            }
        }
        updateColors()
    }
    
    // First tap
    func beginSelection(_ pos: CGPoint) {

        let xPos = Int(pos.x)
        let yPos = Int(pos.y)

        if (xPos > 8 || yPos > 11) {
            return
        }
        
        // If blank return
        if (charPositions[xPos][yPos] == "1") {
            return
        }
        
        // Add selection
        currentWord += charPositions[xPos][yPos]
        selectedPositions.append(pos)
        
        updateColors()
    }
    
    // Helper function to delete a word
    // Confusing function ~~~~
    // What it does: Every valid block that needs to be deleted: Bonus, blank, etc
    // Are added tot he selectedPositions array
    // Then every selected position is removed
    private func deleteWord() {
        
        charactersLeft = charactersLeft - selectedPositions.count
        
        // get bonus
        var bonus: [CGPoint] = []
        
        
        for square in selectedPositions {
            let y = Int(square.y)
            let x = Int(square.x)
            
            if (bonusLetters[x][y] == "2") {
                
                for i in 0..<9 {
                    if (!bonus.contains(CGPoint(x:i,y:y)) && !selectedPositions.contains(CGPoint(x:i,y:y))) {
                        
                        bonus.append(CGPoint(x:i, y:y))
                        bonusLetters[i][y] = "0"
                    }
                }
                bonusLetters[x][y] = "0"
            }
        }
        
        // Add bonus to selectedPositions
        for b in bonus {
            if (!selectedPositions.contains(b)) {
                selectedPositions.append(b)
            }
        }
        
        bonusLettersLeft = bonusLettersLeft - bonus.count
        
        // get blanks
        var blanks: [CGPoint] = []
        for square in selectedPositions {
            let y = Int(square.y)
            let x = Int(square.x)
            
            // Checks for blanks = Add blanks that are neighbors
            if (x > 0 && charPositions[x-1][y] == "1" && !blanks.contains(CGPoint(x:x-1,y:y)))
            {
                blanks.append(CGPoint(x:x-1,y:y))
            }
            if (y > 0 && charPositions[x][y-1] == "1" && !blanks.contains(CGPoint(x:x,y:y-1)))
            {
                blanks.append(CGPoint(x:x,y:y-1))
            }
            if (x < 8 && charPositions[x+1][y] == "1" && !blanks.contains(CGPoint(x:x+1,y:y)))
            {
                blanks.append(CGPoint(x:x+1,y:y))
            }
            if (y < 11 && charPositions[x][y+1] == "1" && !blanks.contains(CGPoint(x:x,y:y+1)))
            {
                blanks.append(CGPoint(x:x,y:y+1))
            }
            
        }
        
        // Add blanks to selectedpositions
        for blank in blanks {
            if (!selectedPositions.contains(blank)) {
                selectedPositions.append(blank)
            }
        }
        
        blanksLeft = blanksLeft - blanks.count
        
        
        // REMOVE SELECTIONS HERE
        
        for i in 0..<selectedPositions.count {
            var y = Int(selectedPositions[i].y)
            let x = Int(selectedPositions[i].x)
            
            // Adjust block and while not at top
            while (y > 0) {
                
                if (selectedPositions.contains(CGPoint(x:x,y:y-1))) {
                    let index = selectedPositions.index(of: CGPoint(x:x,y:y-1))!
                    selectedPositions[index] = CGPoint(x: x, y: y)
                    
                }
                
                // Remove bonus
                if (bonusLetters[x][y-1] == "2") {
                    
                    bonusLetters[x][y] = bonusLetters[x][y-1]
                    bonusLetters[x][y-1] = "0"
                }
                charPositions[x][y] = charPositions[x][y-1]
                
                y = y - 1
            }
            charPositions[x][0] = "0"
            
        }
        score += selectedPositions.count*selectedPositions.count
    }
    
    // Function places words
    private func placeWords() {
        var charsLeft = 98
        
        while (charsLeft != 0) {
      
            var word = getWord()
            
            // If we already have the word get another one
            // Make sure the characters left match the length of word
            if (charsLeft != 2) {
                while(words.contains(word) || charsLeft - word.count == 1 || charsLeft - word.count < 0) {
                    word = getWord()
                }
                
            } else {
                
                while(words.contains(word) || charsLeft - word.count < 0) {
                    word = getWord()
                }
                
            }
  
            words.append(word)
            
            // Add words here
            var lastPos = getFirstOpenPos()
            
            for i in 0..<word.count {
                
                let index = word.index(word.startIndex, offsetBy: i)
                charPositions[Int(lastPos.x)][Int(lastPos.y)] = String(word[index])
                charsLeft = charsLeft - 1
                lastPos = getNextRandPos(point: lastPos)
            }
        }
    }
    
    // Randomly place blanks
    private func placeBlanks() {
        
        for _ in 0..<10 {
            
            var x = Int(arc4random_uniform(8))
            var y = Int(arc4random_uniform(11))
            
            while(charPositions[x][y] == "1") {
                x = Int(arc4random_uniform(8))
                y = Int(arc4random_uniform(11))

            }
            charPositions[x][y] = "1"
        }
    }
    
    // Reads from the list of words and places it in an array
    private func getValidWords() {
        
        let path = Bundle.main.path(forResource: "proj3_dict", ofType: "txt")
        
        let read: NSString = try! NSString.init(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
        
        read.enumerateLines { word, _ in
            self.validWords.append(word)
        }
    }
    
    // Randomly sets bonus letters
    private func setBonusLetters() {
        for _ in 0..<4 {
            var randX = Int(arc4random_uniform(UInt32(9)))
            var randY = Int(arc4random_uniform(UInt32(12)))
            while (bonusLetters[randX][randY] == "2" || charPositions[randX][randY] == "1") {
                randX = Int(arc4random_uniform(UInt32(9)))
                randY = Int(arc4random_uniform(UInt32(12)))
            }
            bonusLetters[randX][randY] = "2"
        }
    }
    
    // checks if valid words has the word
    private func currentWordIsValid() -> Bool {
        return validWords.contains(currentWord)
    }
    
    // Gets word from the array
    private func getWord() -> String {
       
        return validWords[Int(arc4random_uniform(UInt32(validWords.count)))]
    }
    
    // Helper function to find the first open position
    // Used if the word cant be continous or if starting a word
    private func getFirstOpenPos() -> CGPoint {
        for x in 0..<9 {
            for y in 0..<12 {
                
                if (charPositions[x][y] == "0") {
                    return CGPoint(x:x,y:y)
                }
            }
        }
        
        //Should never reach here
        // Should always have room to place character
        return CGPoint(x:0,y:0)
    }
    
    // Calculates the next random position to check
    private func getNextRandPos(point: CGPoint) -> CGPoint {

        var randX = Int(arc4random_uniform(UInt32(3))) - 1 // -1 to 1
        var randY = Int(arc4random_uniform(UInt32(3))) - 1// -1 to 1
        var position = CGPoint(x:Int(point.x) + randX, y:Int(point.y) + randY)
        
        // Track how many positions we check
        var xList: Set = [randX]
        var yList: Set = [randY]
        
        while (!positionIsValid(position) && !(xList.count == 3 && yList.count == 3)) {
            randX = Int(arc4random_uniform(UInt32(3))) - 1  // -1 to 1
            randY = Int(arc4random_uniform(UInt32(3))) - 1
            position = CGPoint(x:Int(point.x) + randX, y:Int(point.y) + randY)
            xList.insert(randX)
            yList.insert(randY)
        }
        
        // If we have checked all positions then it CANT be continous. Must find place somewhere else
        if (xList.count == 3 && yList.count == 3) {
    
            return getFirstOpenPos()
        }
    
        return position
    }
    
    // Update the colors
    private func updateColors() {
        for x in 0..<9 {
            for y in 0..<12 {
                cellColors[x][y] = getSquareColor(x:x, y:y)
            }
        
        }
        delegate?.boardChanged()
    }

    
    // Clear    = 0
    // Green    = 1
    // Red      = 2
    // Black    = 3
    // Yellow   = 4
    // White    = 5
    // THis just has a bunch of checks to see if a square is deletedable. If so its green.
    private func getSquareColor(x: Int, y: Int) -> String {
        
        let point = CGPoint(x:x, y:y)
        if selectedPositions.contains(point) {
            if (currentWordIsValid()) {
                
                return "1"
            } else {
                return "2"
            }
        } else if rowContainsBonus(y: y) && currentWordIsValid() && charPositions[x][y] != "0" {
            return "1"
        }else if (bonusLetters[x][y] == "2" ) {
            //return UIColor.yellow.cgColor
            return "4"
        } else if (charPositions[x][y] == "0") {
            //return UIColor.clear.cgColor
            return "0"
        } else if ( charPositions[x][y] == "1") {
            if ((selectedPositions.contains(CGPoint(x:x-1,y:y))
                || selectedPositions.contains(CGPoint(x:x,y:y-1))
                || selectedPositions.contains(CGPoint(x:x,y:y+1))
                || selectedPositions.contains(CGPoint(x:x+1,y:y)))
                && currentWordIsValid())
            {
                //return UIColor.green.cgColor
                return "1"
            }
            if (y > 0 && rowContainsBonus(y: y-1) && currentWordIsValid()) {
                //return UIColor.green.cgColor
                return "1"
            } else if (y < 11 && rowContainsBonus(y: y+1) && currentWordIsValid()) {
                //return UIColor.green.cgColor
                return "1"
            }
            
            //return UIColor.black.cgColor
            return "3"
        } else{
            //return UIColor.white.cgColor
            return "5"
            }
    }
    
    // Returns if the positon is valid
    private func positionIsValid(_ pos: CGPoint) -> Bool {
        let x = Int(pos.x)
        let y = Int(pos.y)
        
        return (x >= 0 && x < 9) && (y >= 0 && y < 12) && charPositions[x][y] == "0"
    }
    
    // Checks if row has a bonus in it
    private func rowContainsBonus(y: Int) -> Bool {
        for i in 0..<9 {
            if (bonusLetters[i][y] == "2" && selectedPositions.contains(CGPoint(x:i,y:y))) {
                return true
            }
            
        }
        return false
    }
}
    

