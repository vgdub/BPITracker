//
//  NSDateExtension.swift
//  BPI
//
//  Created by Greg Williams on 4/13/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//

extension NSDate {
    
    func beginningOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        return calendar.dateFromComponents(components)!
    }
    
    func endOfDay() -> NSDate {
        let components = NSDateComponents()
        components.day = 1
        var date = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self.beginningOfDay(), options: [])!
        date = date.dateByAddingTimeInterval(-1)
        return date
    }
}