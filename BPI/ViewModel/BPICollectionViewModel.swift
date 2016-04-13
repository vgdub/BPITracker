//
//  BPICollectionViewModel.swift
//  BPI
//
//  Created by Greg Williams on 4/13/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//

import UIKit
import CoreData

protocol BPICollectionViewViewModel {
    var bpiHistory: [BPI] { get }
    var bpiCount: Int { get }
    func loadCollectionData()
}

class BPICollectionViewModel: BPICollectionViewViewModel {
    var bpiHistory = [BPI]()
    
    var bpiCount: Int {
        return bpiHistory.count
    }
    
    var moc:NSManagedObjectContext!
    
    init() {
        moc = CoreDataHelper.managedObjectContext()
        
        BPIDataAccessor().updateHistoricalData()
    }
    
    func loadCollectionData() {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        let fetchedEntities = CoreDataHelper.fetchEntities("BPI", managedObjectContext: moc, predicate: nil, sortDescriptor: sortDescriptor, fetchLimit: 28) as! [BPI]
        
        self.bpiHistory = fetchedEntities.reverse() // reverse retrieved BPI's for graph
        
        print("======== BPI HISTORY ============")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        for bpi in bpiHistory {
            print("\(dateFormatter.stringFromDate(bpi.date)) : \(bpi.rate)")
        }
        print("======== BPI HISTORY END ============")
    }
}
