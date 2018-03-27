//
//  Dataset.swift
//  Elephant
//
//  Created by Caelan Dailey on 2/20/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//
// This file represents the data for alarms
// An alarm has a name, days, repeater, zone, duration, time

import Foundation

// must conform if it has delegate class
protocol AlarmDatasetDelegate: class {
    var delegateID: String { get}
    func datasetUpdated()
}

// The actual data configuration
final class AlarmDataset {
    final class Entry {
        let name: String
        let days: [Int]
        let repeater: String
        let zone: Int
        let duration: TimeInterval
        let time: TimeInterval
        
        init(name: String, days: [Int], repeater: String, zone: Int, duration: TimeInterval, time: TimeInterval) {
            self.name = name
            self.days = days
            self.repeater = repeater
            self.zone = zone
            self.duration = duration
            self.time = time
        }
    }
    
    // Setup delegate
    private final class WeakDatasetDelegate {
        weak var delegate: AlarmDatasetDelegate?
        
        init(delegate: AlarmDatasetDelegate) {
            self.delegate = delegate
        }
    }
    
    // Objects
    // Lock for safety
    private static var entries: [Entry] = []
    private static var entriesLock: NSLock = NSLock()
    private static var delegates: [String: WeakDatasetDelegate] = [:]
    private static var delegatesLock: NSLock = NSLock()
    
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
    
    // Create an entry
    static func appendEntry(_ entry: Entry) {
        
        entriesLock.lock()
        entries.append(entry)
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
        entriesLock.unlock()
        
        delegatesLock.lock()
        delegates.values.forEach({ (weakDelegate: WeakDatasetDelegate) in
            weakDelegate.delegate?.datasetUpdated()
        })
        delegatesLock.unlock()
    }
    
    // Get delegate
    static func registerDelegate(_ delegate: AlarmDatasetDelegate) {
        
        delegatesLock.lock()
        delegates[delegate.delegateID] = WeakDatasetDelegate(delegate: delegate)
        delegatesLock.unlock()
        
        
    }
    
    
}

