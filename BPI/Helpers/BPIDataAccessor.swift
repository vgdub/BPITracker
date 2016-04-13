//
//  BPIDataAccessor.swift
//  BPI
//
//  Created by Greg Williams on 4/12/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//

import UIKit
import CoreData

let CurrentBPIUpdateNotification = "CurrentBPIUpdateNotification"
let HistoricalBPIUpdateNotification = "HistoricalBPIUpdateNotification"

class BPIDataAccessor : NSObject {
    
    typealias Payload = [String: AnyObject]
    
    
    override init() {
        super.init()
        
    }
    
    func beginUpdateCurrentData() {
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self,
            selector: "updateCurrentData", userInfo: nil, repeats: true)
        
        // just so it happens quickly the first time
        updateCurrentData()
    }
    
    
    func updateCurrentData() {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "https://api.coindesk.com/v1/bpi/currentprice/EUR.json")!
        var json: Payload!
        
        session.dataTaskWithURL(url) { data, response, error in
            if error != nil {
                print(error)
                return
            }
            
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String : AnyObject]
                
                guard let currentBPI = json["bpi"] as? Payload else {
                    print("not working")
                    return
                }
                
                guard let euroBPI = currentBPI["EUR"] as? Payload else {
                    print("not working out of current bpi")
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()) { self.saveCurrentBPI(euroBPI) }
            } catch {
                print(error)
            }
            
            }.resume()
    }
    
    func saveCurrentBPI(currentBPI:Payload) {
        // Should pass data here to class responsible for actually taking data and saving to core data
        
        let date = NSDate() // Todays date
        
        let rateString = String(currentBPI["rate_float"]!)
        let rate = Float(rateString)!
        
        BPIManager.addBPI("EUR", rate: rate, date: date) { (bpi) -> () in
            print("Latest BPI: \(bpi.date) - \(bpi.rate)")
            let currentBPIUpdateNotification = NSNotification(name: CurrentBPIUpdateNotification, object: bpi)
            NSNotificationCenter.defaultCenter().postNotification(currentBPIUpdateNotification)

        }
        
        
    }
    
    func updateHistoricalData() {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=EUR")!
        var json: Payload!
        
        session.dataTaskWithURL(url) { data, response, error in
            if error != nil {
                return
            }
            
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? Payload
                
                guard let bpiHistory = json["bpi"] as? Payload else {
                    print("no bpi data")
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()) { self.saveHistoricalBPI(bpiHistory) }
            } catch {
                print(error)
            }
            
            }.resume()
    }
    
    func saveHistoricalBPI(bpiHistory:Payload!) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Should pass data here to class responsible for actually taking data and saving to core data
        for (dateString, rateString) in bpiHistory {
            
            let rate = String(rateString)
            let rateFloat = Float(rate)!
            
            let date = dateFormatter.dateFromString(dateString)
            
            BPIManager.addBPI("EUR", rate: rateFloat, date: date!, completion: nil)
            
            
        }
        
        let historicalBPIUpdateNotification = NSNotification(name: HistoricalBPIUpdateNotification, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(historicalBPIUpdateNotification)
    }
}