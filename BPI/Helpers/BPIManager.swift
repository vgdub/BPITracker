//
//  BPIManager.swift
//  BPI
//
//  Created by Greg Williams on 4/12/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//

import UIKit

class BPIManager: NSObject {
    
    /** 
     Handles creating and updating of BPI
     
     Optionally returns saved BPI completion
    */
    
    class func saveBPI(code code: String, rate: Float, date: NSDate, completion: ((bpi: BPI) -> ())?) {
        let moc = CoreDataHelper.managedObjectContext()
        
        /** Predicate set to check for object with same date */
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", date.beginningOfDay(), date.endOfDay()) // existing entity with date
        
        let bpiList = CoreDataHelper.fetchEntities("BPI", managedObjectContext: moc, predicate: predicate, sortDescriptor: sortDescriptor, fetchLimit: nil) as! [BPI]
        
        /** 
            If a BPI exists then update the rate for that date
            Otherwise create a new BPI object
        */
        if bpiList.count > 0 {
            
            let bpi = bpiList.first! as BPI
            bpi.code = code
            bpi.rate = rate
            bpi.date = date
            try! moc.save()
            
            completion?(bpi: bpi)
        } else {
            let bpi = CoreDataHelper.insertManagedObject("BPI", managedObjectContext: moc) as! BPI
            bpi.code = code
            bpi.rate = rate
            bpi.date = date
            try! moc.save()
            
            completion?(bpi: bpi)
        }
        
        
    }

}
