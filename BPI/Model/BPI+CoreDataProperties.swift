//
//  BPI+CoreDataProperties.swift
//  BPI
//
//  Created by Greg Williams on 4/12/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BPI {

    @NSManaged var code: String
    @NSManaged var rate: NSNumber
    @NSManaged var date: NSDate

}
