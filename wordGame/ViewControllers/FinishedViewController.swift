//
//  wordGame
//
//  Created by Caelan Dailey on 3/26/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import Foundation
import UIKit

// This view is used for games that are FINISHED
// Loads data from the FINISHED dataset and presents it
// Thats all it does, no delegates between game and view
class FinishedViewController: UIViewController, FinishedDatasetDelegate {
    
    // Position in table
    private let index: Int
    
    // Custom delegate
    let delegateID: String = UIDevice.current.identifierForVendor!.uuidString
    
    // Board view object
    private var boardView: BoardControl {
        return view as! BoardControl
    }
    
    
    // Initilaizer for existing games
    init(withIndex: Int) {

        index = withIndex
        super.init(nibName: nil, bundle: nil)
        
        // Set delegates
  
        FinishedDataset.registerDelegate(self)
        
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
        datasetUpdated()
    }
    
    // Function updates all needed data
    // Function called when initializing
    func datasetUpdated() {
        // Get entry
        let entry = FinishedDataset.entry(atIndex: index)
        
        let score = entry.score
        
        // Set view
        boardView.score = score
        boardView.gameWon = true
    }
}

