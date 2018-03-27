//
//  BoardControl.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/16/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import Foundation
import UIKit

protocol  BoardControlDelegate: AnyObject {
    func cellTouchesBegan(_ pos: CGPoint)
    func cellTouchesMoved(_ pos: CGPoint)
    func cellTouchesEnded(_ pos: CGPoint)
}
// 9 x 12 board 9X 12Y
class BoardControl: UIControl {

    private var currentPosition = CGPoint(x: 0, y: 0)

    private var selectedPositions = [CGPoint]() //= [(0,1),(0,2),(1,1),(2,1),(2,2)]

    private var charPositions = Array(repeatElement(Array(repeatElement("0", count: 12)), count: 9))

    private var words: [String] = []
    
    private var validWords: [String] = []
    
    private var currentWord = ""
    
    private var bonusLetters = Array(repeatElement(Array(repeatElement("0", count: 12)), count: 9))
    
    private var charactersLeft = 94
    
    private var blanksLeft = 10
    
    private var bonusLettersLeft = 4
    
    private var score = 0
    
    weak var delegate: BoardControlDelegate? = nil

// Required
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        getValidWords()
        placeBlanks()
        placeWords()
        setBonusLetters()
    }
/*
var value: (Int, Int) {
    get {
        return position
    } set {
        position = newValue
    }
}
 */
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Setup view
        context.clear(bounds)
        context.setFillColor((backgroundColor ?? UIColor.white).cgColor)
        context.fill(bounds)
        
        let width = self.bounds.width/9
        let height = self.bounds.height/12
        
        /*
         for y in 1...11 {
         let line: CGRect = CGRect(x: 0, y: CGFloat(y) * height, width: self.bounds.width , height: 2)
         context.setFillColor(UIColor.black.cgColor)
         context.fill(line)
         }
         
         for x in 1...8 {
         let line: CGRect = CGRect(x: CGFloat(x) * width-1, y: 0, width: 2 , height: self.bounds.height)
         context.setFillColor(UIColor.black.cgColor)
         context.fill(line)
         }
         
         */
        
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
                context.setFillColor(getSquareColor(x: x, y: y))
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
            //line.fill()    // Fill it
        }
        
        // Characters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        /*
         for y in 0...11 {
         for x in 0...8 {
         
         let textLabel = UILabel()
         textLabel.text = "Y"
         textLabel.numberOfLines = 0
         textLabel.textAlignment = .center
         let stringFrame: CGRect = CGRect(x: CGFloat(x) * width, y: CGFloat(y) * height, width: width , height: height)
         textLabel.frame = stringFrame
         
         self.addSubview(textLabel)
         
         }
         }
         */
        
        
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
                
                
                let stringValue = charPositions[x][11-y]
                // Create and draw
                var attribute = NSAttributedString(string: stringValue, attributes: styles)
                var setter = CTFramesetterCreateWithAttributedString(attribute as CFAttributedString)
                
                var frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, attribute.length), path, nil)
                
                if(charPositions[x][11-y] != "1" && charPositions[x][11-y] != "0") {
                    CTFrameDraw(frame, context)
                }
            }
        }
        
        
        
        
    }
    
    private func placeBlanks() {
        
        for _ in 0..<10 {
            
            var x = Int(arc4random_uniform(8))
            var y = Int(arc4random_uniform(11))
            
            while(charPositions[x][y] == "1") {
                x = Int(arc4random_uniform(8))
                y = Int(arc4random_uniform(11))
                print("landed on 1")
            }
            charPositions[x][y] = "1"
        }
        print("done")
    }
    
    private func placeWords() {
        var charsLeft = 98
        
        while (charsLeft != 0) {
            var word = getWord()
            print("testing word")
            if (charsLeft != 2) {
                while(words.contains(word) || charsLeft - word.count == 1 || charsLeft - word.count < 0) {
                    word = getWord()
                    print(charsLeft)
                    print("newword1")
                }
                
            } else {
                
                while(words.contains(word) || charsLeft - word.count < 0) {
                    word = getWord()
                    print("newword2")
                }
                
            }
            words.append(word)
            print("gotword")
            
            var count = word.count
            var lastPos = getFirstOpenPos()
            
            for i in 0..<count {
                
                let index = word.index(word.startIndex, offsetBy: i)
                charPositions[Int(lastPos.x)][Int(lastPos.y)] = String(word[index])
                charsLeft = charsLeft - 1
                lastPos = getNextRandPos(point: lastPos)
            }
        }
    }
    
    private func getNextRandPos(point: CGPoint) -> CGPoint {
        print("rand")
        var randX = Int(arc4random_uniform(UInt32(3))) - 1 // -1 to 1
        var randY = Int(arc4random_uniform(UInt32(3))) - 1// -1 to 1
        var position = CGPoint(x:Int(point.x) + randX, y:Int(point.y) + randY)
        var xList: Set = [randX]
        var yList: Set = [randY]
        
        
        while (!positionIsValid(position) && !(xList.count == 3 && yList.count == 3)) {
            randX = Int(arc4random_uniform(UInt32(3))) - 1  // -1 to 1
            randY = Int(arc4random_uniform(UInt32(3))) - 1
            position = CGPoint(x:Int(point.x) + randX, y:Int(point.y) + randY)
            xList.insert(randX)
            yList.insert(randY)
            
            print("newRandom")
            print(xList)
            print(yList)
            print(!positionIsValid(position))
            print(!(xList.count == 3 && yList.count == 3))
            print(!positionIsValid(position) && !(xList.count == 3 && yList.count == 3))
        }
        
        if (xList.count == 3 && yList.count == 3) {
            print("returning first open pos")
            return getFirstOpenPos()
            
        }
     
        return position
    }
    
    private func positionIsValid(_ pos: CGPoint) -> Bool {
        let x = Int(pos.x)
        let y = Int(pos.y)
        
        return (x >= 0 && x < 9) && (y >= 0 && y < 12) && charPositions[x][y] == "0"
    }
    
    private func getFirstOpenPos() -> CGPoint {
        for x in 0..<9 {
            for y in 0..<12 {
                
                if (charPositions[x][y] == "0") {
                    return CGPoint(x:x,y:y)
                }
            }
        }
        
        //Should never reach here
        print("SHOULDNT HAVE REACHED HERE")
        return CGPoint(x:0,y:0)
    }
    private func getWord() -> String {
        
        return validWords[Int(arc4random_uniform(UInt32(validWords.count)))]
    }

    private func rowContainsBonus(y: Int) -> Bool {
        for i in 0..<9 {
            if (bonusLetters[i][y] == "2" && selectedPositions.contains(CGPoint(x:i,y:y))) {
                return true
            }
            
        }
        
        return false
        
    }
    private func getSquareColor(x: Int, y: Int) -> CGColor {

        let point = CGPoint(x:x, y:y)
        if selectedPositions.contains(point) {
            if (currentWordIsValid()) {
                 return UIColor.green.cgColor
            } else {
                return UIColor.red.cgColor
            }
        } else if rowContainsBonus(y: y) && currentWordIsValid() && charPositions[x][y] != "0" {
            return UIColor.green.cgColor
        }else if (bonusLetters[x][y] == "2" ) {
            return UIColor.yellow.cgColor
        } else if (charPositions[x][y] == "0") {
            return UIColor.clear.cgColor
        } else if ( charPositions[x][y] == "1") {
            if ((selectedPositions.contains(CGPoint(x:x-1,y:y))
                || selectedPositions.contains(CGPoint(x:x,y:y-1))
                || selectedPositions.contains(CGPoint(x:x,y:y+1))
                || selectedPositions.contains(CGPoint(x:x+1,y:y)))
                && currentWordIsValid())
            {
                return UIColor.green.cgColor
            }
            if (y > 0 && rowContainsBonus(y: y-1) && currentWordIsValid()) {
                return UIColor.green.cgColor
            } else if (y < 11 && rowContainsBonus(y: y+1) && currentWordIsValid()) {
                return UIColor.green.cgColor
            }
            
            return UIColor.black.cgColor
        } else{
            return UIColor.white.cgColor
        }
        /*
        for square in selectedPositions {
            if (Int(square.x) == x && Int(square.y) == y) {
                return UIColor.green.cgColor
            }
        }
        
        return UIColor.white.cgColor
        */
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
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
     
        if (charPositions[xPos][yPos] == "0" || charPositions[xPos][yPos] == "1") {
            return
        }
        var isNotClose = true
        for square in selectedPositions {
            if abs(Int(square.x) - xPos) < 2 && abs(Int(square.y) - yPos) < 2 {
                isNotClose = false
            }
        }
        if (isNotClose) {
            return
        }
        
        if (!selectedPositions.contains(position)) {
            selectedPositions.append(position)
            currentPosition = position
            currentWord += charPositions[xPos][yPos]
     
            print(currentWord)
            print(currentWordIsValid())
        } else {
            let count = selectedPositions.count
            if (count > 1) {
                if (selectedPositions[count-2] == position) {
                    selectedPositions.removeLast()
                    let endIndex = currentWord.index(currentWord.endIndex, offsetBy: -1)
                    currentWord = String(currentWord[..<endIndex])
                    print(currentWord)
                }
            }
        }
        
        
        setNeedsDisplay()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touch: UITouch = touches.first!
        let locationIsnSelf: CGPoint = touch.location(in: self)
        
        let width = self.bounds.width/9
        let height = self.bounds.height/12
        
        let xPos = Int(locationIsnSelf.x/width)
        let yPos = Int(locationIsnSelf.y/height)
        
        print(xPos)
        print(yPos)
        
        let position = CGPoint(x: xPos, y: yPos)
        
        delegate?.cellTouchesBegan(position)
        
        print("below")
        print(charPositions[xPos][yPos])
        if (charPositions[xPos][yPos] == "1") {
            return
        }
        currentWord += charPositions[xPos][yPos]
        print(currentWord)
        
        selectedPositions.append(position)
        print(selectedPositions)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touch: UITouch = touches.first!
        let locationIsnSelf: CGPoint = touch.location(in: self)

        
        delegate
        
     
        //placeWords()
        setNeedsDisplay()

        
        
    }
    
    private func deleteWord() {
        
        charactersLeft = charactersLeft - selectedPositions.count
        
        // get bonus
        var bonus: [CGPoint] = []
        
        for square in selectedPositions {
            var y = Int(square.y)
            let x = Int(square.x)
            
            if (bonusLetters[x][y] == "2") {
                
                for i in 0..<9 {
                    if (!bonus.contains(CGPoint(x:i,y:y)) && !selectedPositions.contains(CGPoint(x:i,y:y))) {
                        print("added BONUS")
                        bonus.append(CGPoint(x:i, y:y))
                        bonusLetters[x][y] = "0"
                    }
                }
                
            }
        }
        
        for b in bonus {
            if (!selectedPositions.contains(b)) {
                selectedPositions.append(b)
            }
        }
        
        bonusLettersLeft = bonusLettersLeft - bonus.count
                
        // get blanks
        var blanks: [CGPoint] = []
        for square in selectedPositions {
            var y = Int(square.y)
            let x = Int(square.x)
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
                print("HERERERERERERERE")
                print("caelan")
            }
            if (y < 11 && charPositions[x][y+1] == "1" && !blanks.contains(CGPoint(x:x,y:y+1)))
            {
                blanks.append(CGPoint(x:x,y:y+1))
            }
            
        }
        for blank in blanks {
            if (!selectedPositions.contains(blank)) {
                selectedPositions.append(blank)
            }
        }
        blanksLeft = blanksLeft - blanks.count
        
        for i in 0..<selectedPositions.count {
            var y = Int(selectedPositions[i].y)
            let x = Int(selectedPositions[i].x)
            
            
            while (y > 0) {
                
                if (selectedPositions.contains(CGPoint(x:x,y:y-1))) {
                    let index = selectedPositions.index(of: CGPoint(x:x,y:y-1))!
                    selectedPositions[index] = CGPoint(x: x, y: y)
                    
                }
                if (bonusLetters[x][y-1] == "2") {
                    
                    bonusLetters[x][y] = bonusLetters[x][y-1]
                    bonusLetters[x][y-1] = "0"
                }
                charPositions[x][y] = charPositions[x][y-1]
                
                y = y - 1
            }
            charPositions[x][0] = "0"
            
        }
        
    }
    
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
    
    private func currentWordIsValid() -> Bool {
        print("Current word is")
        print(currentWord)
        return validWords.contains(currentWord)
    }
    
    private func getValidWords() {
        
        let path = Bundle.main.path(forResource: "proj3_dict", ofType: "txt")
        
        let read: NSString = try! NSString.init(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
        
        read.enumerateLines { word, _ in
            self.validWords.append(word)
        }
    }
}
