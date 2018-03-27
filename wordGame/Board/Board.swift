//
//  Board.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/25/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import Foundation

protocol BoardDelegate: AnyObject {
    func boardChanged()
}

// CALL delegate.boardChanged() when values changed
class Board {
    
    weak var delegate: BoardDelegate? = nil
    
    func resetSelections() {
        
        if (selectedPositions.count > 1 && currentWordIsValid()) {
            deleteWord()
        }
        
        selectedPositions.removeAll()
        currentWord = ""
    
    }
}
