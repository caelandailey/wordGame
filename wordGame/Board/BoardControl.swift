//
//  BoardControl.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/16/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import Foundation
import UIKit

// Delegate protocl

protocol  BoardControlDelegate: AnyObject {
    func cellTouchesBegan(_ pos: CGPoint)
    func cellTouchesMoved(_ pos: CGPoint)
    func cellTouchesEnded()
}

// This class represents the view for a GAME
// View takes in selected positions, character positions, and cell colors
// Based on these values, different characters are presented and different cell backgrounds are chosen

// Colors =
// Red = Selected but can't be removed
//  White   = Normal
//  Black   = Empty space
//  Yellow  = Bonus letter
//  Green  = Selected and can remove word
//  Clear = NO block
class BoardControl: UIControl {
    
    var selectedPositions = [CGPoint]() //= [(0,1),(0,2),(1,1),(2,1),(2,2)]
    {
        didSet {
            setNeedsDisplay()
        }
    }

    var charPositions = Array(repeatElement(Array(repeatElement("0", count: 12)), count: 9))
    {
        didSet {
            setNeedsDisplay()
            
        }
    }
    
    var cellColors = Array(repeatElement(Array(repeatElement(UIColor.clear.cgColor, count: 12)), count: 9))
    {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var gameWon = false
    {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var score: Int = 0
    {
        didSet {
            setNeedsDisplay()
            print("changed score")
        }
    }
    weak var delegate: BoardControlDelegate? = nil
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("PRINTING SCREEEN!!!!~~~~~~~~~~~~~~~~~~~~~~~~")
   
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Setup view
        context.clear(bounds)
        context.setFillColor((backgroundColor ?? UIColor.white).cgColor)
        context.fill(bounds)
        
        let width = self.bounds.width/9
        let height = self.bounds.height/12
        
        // SQUARES ~~~~~~~~~~~~~~~
        let borderColor = UIColor.groupTableViewBackground.cgColor
        
        for y in 0...11 {
            for x in 0...8 {
                // Border
                let border: CGRect = CGRect(x: CGFloat(x) * width, y: CGFloat(y) * height, width: width , height: height)
                context.setFillColor(borderColor)
                context.fill(border)
                
                // Square
                let square: CGRect = CGRect(x: CGFloat(x) * width + 1, y: CGFloat(y) * height + 1, width: width-2 , height: height-2)
                context.setFillColor(cellColors[x][y])
                context.fill(square)
            }
        }
        
        // LINES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        let count = selectedPositions.count
        
        let line = UIBezierPath()
        line.lineJoinStyle = CGLineJoin.round
        
        
        if (count > 1) {
            
            let line = UIBezierPath()
            line.lineJoinStyle = CGLineJoin.round
            
            let square1 = selectedPositions[0]
            
            line.move(to: CGPoint(x: CGFloat(square1.x)*width+width/2,
                                  y: CGFloat(square1.y)*height + height/2))
            
            for i in 1..<count {
                
                let square = selectedPositions[i]
                
                line.addLine(to: CGPoint(x:CGFloat(square.x) * width + width/2,
                                         y: CGFloat(square.y) * height + height/2)) // Point B
                line.close()
                
                line.move(to: CGPoint(x:CGFloat(square.x) * width + width/2,
                                      y: CGFloat(square.y) * height + height/2)) // Point B
            }
            
            
            line.lineWidth = CGFloat(width/3)    // Set width
            
            
            UIColor.white.set()         // Set color
            line.stroke(with: CGBlendMode.normal, alpha: 0.75)  // Draw line
        }
        
        // Characters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        // Text
        // Configure
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // Styles
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        var styles: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): style]
        styles[NSAttributedStringKey.font] = UIFont(name: "DINCondensed-Bold", size: 16 )
        styles[NSAttributedStringKey.foregroundColor] = UIColor.darkGray
        
        for x in 0..<9 {
            for y in 0..<12 {
                
                // Box
                let path = CGMutablePath()
                let stringFrame: CGRect = CGRect(x: CGFloat(x) * width, y: CGFloat(y) * height - height * 0.4, width: width , height: height)
                path.addRect(stringFrame)
                
                // Starts at 11-y because its backwards. context is flipped
                let stringValue = charPositions[x][11-y]
                
                // Create and draw
                let attribute = NSAttributedString(string: stringValue, attributes: styles)
                let setter = CTFramesetterCreateWithAttributedString(attribute as CFAttributedString)
                
                let frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, attribute.length), path, nil)
                
                if(charPositions[x][11-y] != "1" && charPositions[x][11-y] != "0") {
                    CTFrameDraw(frame, context)
                }
            }
        }
        
        if (!gameWon) {
            return
        }
        print("here")
        // Box
        var path = CGMutablePath()
        var stringFrame: CGRect = CGRect(x: 0, y: self.bounds.height*2/3, width: self.bounds.width , height: self.bounds.width/4)
        
        path.addRect(stringFrame)
        
        // Starts at 11-y because its backwards. context is flipped
        var stringValue = "YOU WON!!"
        styles[NSAttributedStringKey.font] = UIFont(name: "DINCondensed-Bold", size: 64 )
        
        // Create and draw
        var attribute = NSAttributedString(string: stringValue, attributes: styles)
        var setter = CTFramesetterCreateWithAttributedString(attribute as CFAttributedString)
        
        var frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, attribute.length), path, nil)
        
        
        CTFrameDraw(frame, context)
        
       
        stringFrame = CGRect(x: 0, y: self.bounds.height/2, width: self.bounds.width , height: self.bounds.width/8)
        
        path = CGMutablePath()
        path.addRect(stringFrame)
        stringValue = "With a score of: " + String(score)
        styles[NSAttributedStringKey.font] = UIFont(name: "DINCondensed-Bold", size: 24 )
        attribute = NSAttributedString(string: stringValue, attributes: styles)
        setter = CTFramesetterCreateWithAttributedString(attribute as CFAttributedString)
        
        frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, attribute.length), path, nil)
        CTFrameDraw(frame, context)
        
    }

    //Used for delegate ~~~~~~~~~~~~~~~~~~ Gets position in grid and outputs it
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if (gameWon) {
            return
        }
        if (selectedPositions.count == 0) {
            return
        }
        let touch: UITouch = touches.first!
        let locationIsnSelf: CGPoint = touch.location(in: self)
        
        let width = self.bounds.width/9
        let height = self.bounds.height/12
        
        let xPos = Int(locationIsnSelf.x/width)
        let yPos = Int(locationIsnSelf.y/height)
        
        let position = CGPoint(x: xPos, y: yPos)
        
        if (xPos > 8 || yPos > 11 || xPos < 0 || yPos < 0)
        {
            return
        }
        
        
        delegate?.cellTouchesMoved(position)
        
        //setNeedsDisplay()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        print("touches began")
        if (gameWon) {
            return
        }
        let touch: UITouch = touches.first!
        let locationIsnSelf: CGPoint = touch.location(in: self)
        
        let width = self.bounds.width/9
        let height = self.bounds.height/12
        
        let xPos = Int(locationIsnSelf.x/width)
        let yPos = Int(locationIsnSelf.y/height)
        
        let position = CGPoint(x: xPos, y: yPos)
        
        if (xPos > 8 || yPos > 11 || xPos < 0 || yPos < 0)
        {
            return
        }
        
        delegate?.cellTouchesBegan(position)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if (gameWon) {
            return
        }
        delegate?.cellTouchesEnded()
        
    }
}
