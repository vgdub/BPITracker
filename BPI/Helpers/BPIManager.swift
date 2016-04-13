//
//  BPIManager.swift
//  BPI
//
//  Created by Greg Williams on 4/12/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//

import UIKit

class BPIManager: NSObject {
    
    class func addBPI(code: String, rate: Float, date: NSDate, completion: ((bpi: BPI) -> ())?) {
        let moc = CoreDataHelper.managedObjectContext()
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let predicate = NSPredicate(format: "date = %@", date)
        
        let bpiList = CoreDataHelper.fetchEntities("BPI", managedObjectContext: moc, predicate: predicate, sortDescriptor: sortDescriptor, fetchLimit: nil) as! [BPI]
        
        if bpiList.count > 0 {
            print("Count of this date is: \(bpiList.count)")
            // If a bpi exists then update the rate for that date
            let bpi = bpiList.first! as BPI
            bpi.rate = rate
            try! moc.save()
            completion?(bpi: bpi)
        } else {
            // If the bpi doesn't exist create the entity
            let bpi = CoreDataHelper.insertManagedObject("BPI", managedObjectContext: moc) as! BPI
            bpi.code = "EUR"
            bpi.rate = rate
            bpi.date = date
            completion?(bpi: bpi)
        }
        
        
    }

}
