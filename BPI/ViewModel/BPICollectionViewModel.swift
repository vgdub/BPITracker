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
    
    /** Get the number of BPI's in the collection */
    var bpiCount: Int {
        return bpiHistory.count
    }
    
    var moc:NSManagedObjectContext!
    
    init() {
        moc = CoreDataHelper.managedObjectContext()
        
        BPIDataAccessor().updateHistoricalData()
    }
    
    /** Loads collection data from core data with fetchLimit of 28
     
     Sets bpiHistory array to retrieved data
     
    */
    func loadCollectionData() {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let collectionLength = 28
        
        let fetchedEntities = CoreDataHelper.fetchEntities("BPI", managedObjectContext: moc, predicate: nil, sortDescriptor: sortDescriptor, fetchLimit: collectionLength) as! [BPI]
        
        bpiHistory = fetchedEntities.reverse()
    }
}
