//
//  BPIViewModel.swift
//  BPI
//
//  Created by Greg Williams on 4/12/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//

import UIKit
import CoreData

protocol CurrentBPIViewViewModel {
    var bpiRate: String { get }
    var bpiCode: String? { get }
    var bpiDate: String? { get }
}

class CurrentBPIViewModel: CurrentBPIViewViewModel {
    
    var bpiRate: String
    var bpiCode: String?
    var bpiDate: String?
    var moc:NSManagedObjectContext!
    
    init() {
        moc = CoreDataHelper.managedObjectContext()
        
        self.bpiCode = "EUR"
        self.bpiRate = "€---.---"
        self.bpiDate = formattedDate(NSDate())
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let bpiList = CoreDataHelper.fetchEntities("BPI", managedObjectContext: moc, predicate: nil, sortDescriptor: sortDescriptor, fetchLimit: 1) as! [BPI]
        
        if bpiList.count > 0 {
            let bpi = bpiList.first!
            self.bpiCode = bpi.code
            self.bpiRate = "€\(bpi.rate)"
            self.bpiDate = formattedDate(bpi.date)
        }
        
        BPIDataAccessor().beginUpdateCurrentData()
    }
    
    init(_ bpi: BPI) {
        
        self.bpiCode = bpi.code
        self.bpiRate = "€\(bpi.rate)"
        self.bpiDate = formattedDate(bpi.date)
        
    }
        
    func formattedDate(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy hh:mm:ss"
        
        return dateFormatter.stringFromDate(date)
    }
    
}
