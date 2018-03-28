//
//  GamePreview.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/27/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import Foundation
import UIKit

// Preview of game status used in tableview cell
// Just shows the blocks/colors of the game
// Takes in game color array and prints out display
class GamePreview: UIView {
    
    // Represents the colors to present
    var cellColors = Array(repeatElement(Array(repeatElement(UIColor.clear.cgColor, count: 12)), count: 9))
    {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let width = self.bounds.width/9
        let height = self.bounds.height/12
        
        // Setup view
        context.clear(bounds)
        context.setFillColor((backgroundColor ?? UIColor.white).cgColor)
        context.fill(bounds)
        
        for y in 0...11 {
            for x in 0...8 {
                // Square
                let square: CGRect = CGRect(x: CGFloat(x) * width , y: CGFloat(y) * height , width: width , height: height)
               
                context.setFillColor(cellColors[x][y])
                context.fill(square)
            }
        }
    }
}
