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
    
    var bpi: BPI
    var bpiRate: String
    var bpiCode: String?
    var bpiDate: String?
    var moc:NSManagedObjectContext!
    
    init() {
        moc = CoreDataHelper.managedObjectContext()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let bpiList = CoreDataHelper.fetchEntities("BPI", managedObjectContext: moc, predicate: nil, sortDescriptor: sortDescriptor, fetchLimit: 1) as! [BPI]
        self.bpi = bpiList.first!
        self.bpiCode = "EUR"
        self.bpiRate = "---"
        self.bpiDate = formattedDate(NSDate())
    }
    
    init(_ bpi: BPI) {
        
        self.bpi = bpi
        
        self.bpiCode = bpi.code
        self.bpiRate = "€\(bpi.rate)"
        self.bpiDate = formattedDate(bpi.date)
        
    }
        
    func formattedDate(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.stringFromDate(date)
    }
    
}
