//
//  BPIDataAccessor.swift
//  BPI
//
//  Created by Greg Williams on 4/12/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//

import UIKit

let CurrentBPIUpdateNotification = "CurrentBPIUpdateNotification"
let HistoricalBPIUpdateNotification = "HistoricalBPIUpdateNotification"

class BPIDataAccessor : NSObject {
    
    typealias Payload = [String: AnyObject]
    
    
    override init() {
        super.init()
        
    }
    
    /** 
     Sets NSTimer to continuously call updateCurrentData: every 5s
     Calls updateCurrentData: immediately to avoid waiting for first NSTimer call
    */
    func beginUpdateCurrentData() {
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self,
            selector: "updateCurrentData", userInfo: nil, repeats: true)
        
        updateCurrentData()
    }
    
    
    func updateCurrentData() {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "https://api.coindesk.com/v1/bpi/currentprice/EUR.json")!
        var json: Payload!
        
        session.dataTaskWithURL(url) { data, response, error in
            if error != nil {
                let nsError = error! as NSError
                print(nsError.localizedDescription)
                return
            }
            
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String : AnyObject]
                
                guard let currentBPI = json["bpi"] as? Payload else {return }
                guard let euroBPI = currentBPI["EUR"] as? Payload else { return }
                
                dispatch_async(dispatch_get_main_queue()) { self.saveCurrentBPI(euroBPI) }
            } catch {
                let nsError = error as NSError
                print(nsError.localizedDescription)
            }
            
            }.resume()
    }
    
    func saveCurrentBPI(currentBPI:Payload) {
        let date = NSDate() // Todays date
        
        let rateString = String(currentBPI["rate_float"]!)
        let rate = Float(rateString)!
        
        BPIManager.saveBPI(code: "EUR", rate: rate, date: date) { (bpi) -> () in
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
                let nsError = error! as NSError
                print(nsError.localizedDescription)
                return
            }
            
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? Payload
                
                guard let bpiHistory = json["bpi"] as? Payload else { return }
                
                dispatch_async(dispatch_get_main_queue()) { self.saveHistoricalBPI(bpiHistory) }
            } catch {
                let nsError = error as NSError
                print(nsError.localizedDescription)
            }
            
            }.resume()
    }
    
    func saveHistoricalBPI(bpiHistory:Payload!) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for (dateString, rateString) in bpiHistory {
            
            let rate = String(rateString)
            let rateFloat = Float(rate)!
            
            let date = dateFormatter.dateFromString(dateString)
            
            BPIManager.saveBPI(code: "EUR", rate: rateFloat, date: date!, completion: nil)
            
        }
        
        let historicalBPIUpdateNotification = NSNotification(name: HistoricalBPIUpdateNotification, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(historicalBPIUpdateNotification)
    }
}