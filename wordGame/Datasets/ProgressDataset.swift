//
//
//  Created by Caelan Dailey on 2/20/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//
// This file represents the data for alarms
// An alarm has a name, days, repeater, zone, duration, time

import Foundation
import UIKit

// must conform if it has delegate class
protocol ProgressDatasetDelegate: class {
    var delegateID: String { get}
    func datasetUpdated()
}

// The actual data configuration
final class ProgressDataset {
    final class Entry: Codable {
        
        
        
        enum CodingKeys: String, CodingKey {
            case score
            case cellColors
            case charPositions
            case bonusLetters
        }
        let score: Int
        let cellColors: [[String]]
        let charPositions: [[String]]
        let bonusLetters: [[String]]
        
        
        init(score: Int, cellColors: [[String]], charPositions: [[String]], bonusLetters: [[String]]) {

            self.score = score
            self.cellColors = cellColors
            self.charPositions = charPositions
            self.bonusLetters = bonusLetters
        }

    }
    
    // Setup delegate
    private final class WeakDatasetDelegate {
        weak var delegate: ProgressDatasetDelegate?
        
        init(delegate: ProgressDatasetDelegate) {
            self.delegate = delegate
        }
    }
    
    private static let entriesEncoder: JSONEncoder = {
        let entriesEncoder = JSONEncoder()
        entriesEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return entriesEncoder
    }()
    
    // Objects
    // Lock for safety
    
    private static var entriesLock: NSLock = NSLock()
    private static var delegates: [String: WeakDatasetDelegate] = [:]
    private static var delegatesLock: NSLock = NSLock()
    private static var entries: [Entry] = loadData()
    
    // Count important for table rows
    static var count: Int {
        var count: Int = 0
        
        entriesLock.lock()
        count = entries.count
        entriesLock.unlock()
        
        return count
    }
    
    // Delete everything when loading from file
    static func deleteAll(){
        entriesLock.lock()
        entries.removeAll()
        saveData()
        entriesLock.unlock()
    }
    
    // Get an entry object
    static func entry(atIndex index: Int) -> Entry {
        var entry: Entry?
        
        entriesLock.lock()
        entry = entries[index]
        entriesLock.unlock()
        return entry!
    }
    
    private static func loadData() -> [Entry] {
        var loadedData: [Entry] = []

        guard
            let fileURL: URL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("ProgressDataset.json", isDirectory: false),
            let encodedDataset: Data = try? Data(contentsOf: fileURL, options: [])
            
            else {
                print("3")
                
                return []
        }
        do {
            loadedData = try JSONDecoder().decode([Entry].self, from: encodedDataset)

        }catch {
            print(error.localizedDescription)
            
        }

        return loadedData
    }
    
    private static func saveData() {

        guard
            let fileURL: URL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("ProgressDataset.json", isDirectory: false),
            let encodedDataset: Data = try? entriesEncoder.encode(entries)
        else {
            print("failed")
            return
        }
        do {
            try encodedDataset.write(to: fileURL, options: [.atomic, .completeFileProtection])
            //print(fileURL.absoluteString)
            //(String(data: encodedDataset, encoding: .utf8) ?? "")
        }catch {
            print(error.localizedDescription)
            
        }

    }
    
    // Sorts the data
    // How it works: Takes index and places it at the start and shifts everything over
    static func sortData(index: Int) {

        let tempVal = entries[index]

        if entries.count < 2 || index == 0 {
            return
        }

        var last = entries [0]

        // Loop through
        for i in 0..<entries.count-1 {

            let temp = entries[i+1]
            entries[i+1] = last
            last = temp
            
            // If at index stop sorting
            if (( i + 1) == index) {
                print(temp)
                entries[0] = tempVal
                saveData()
                return
                
            }
            
        }
        
    }
 
    // Create an entry
    static func appendEntry(_ entry: Entry) {
        
        entriesLock.lock()
        entries.append(entry)
       
        saveData()
        entriesLock.unlock()
        
        delegatesLock.lock()
        delegates.values.forEach({ (weakDelegate: WeakDatasetDelegate) in
            weakDelegate.delegate?.datasetUpdated()
        })
        delegatesLock.unlock()
        
    }
    
    // Delete an entry when deleted from table
    static func deleteEntry(atIndex index: Int) {
        entriesLock.lock()
        entries.remove(at: index)
        saveData()
        entriesLock.unlock()
        
        delegatesLock.lock()
        delegates.values.forEach({ (weakDelegate: WeakDatasetDelegate) in
            weakDelegate.delegate?.datasetUpdated()
        })
        delegatesLock.unlock()
    }
    
    // Can edit entry on tableview when selecting row
    static func editEntry(atIndex index: Int, newEntry entry: Entry) {
        
        entriesLock.lock()
        entries[index] = entry
       
        saveData()
        entriesLock.unlock()
        
        delegatesLock.lock()
        delegates.values.forEach({ (weakDelegate: WeakDatasetDelegate) in
            weakDelegate.delegate?.datasetUpdated()
        })
        delegatesLock.unlock()
    }
    
    // Get delegate
    static func registerDelegate(_ delegate: ProgressDatasetDelegate) {
        
        delegatesLock.lock()
        delegates[delegate.delegateID] = WeakDatasetDelegate(delegate: delegate)
        delegatesLock.unlock()

    }
    
    
}

