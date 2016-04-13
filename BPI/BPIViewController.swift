//
//  BPIViewController.swift
//  BPI
//
//  Created by Greg Williams on 4/12/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//

import UIKit
import CoreData

class BPIViewController: UIViewController {
    
    @IBOutlet weak var currentBPILabel: UILabel!
    
    var moc:NSManagedObjectContext!
    var bpiDataAccessor:BPIDataAccessor!
    
    var bpiHistory = [BPI]()

    var currentBPIViewModel:CurrentBPIViewModel? {
        didSet {
            currentBPILabel.text = currentBPIViewModel!.bpiRate
        }
    }
    
    var historicalBPIViewModel:CurrentBPIViewModel? {
        didSet {
            // set data to graph
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moc = CoreDataHelper.managedObjectContext()
        bpiDataAccessor = BPIDataAccessor()
        
//        loadCurrentBPIData()
        loadHistoricalData()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onCurrentBPIUpdateNotification:",
            name: CurrentBPIUpdateNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onHistoricalBPIUpdateNotification:",
            name: HistoricalBPIUpdateNotification,
            object: nil)
        
        
        bpiDataAccessor.beginUpdateCurrentData()
        bpiDataAccessor.updateHistoricalData()
        
    }
    
    
    func loadCurrentBPIData() {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        
        bpiHistory = CoreDataHelper.fetchEntities("BPI", managedObjectContext: moc, predicate: nil, sortDescriptor: sortDescriptor, fetchLimit: 1) as! [BPI]
        
        for bpi in bpiHistory {
            print("Most Recent BPI: \(bpi.date) : \(bpi.rate)")
        }
        
        self.currentBPIViewModel = CurrentBPIViewModel(bpiHistory.first!)
    }
    
    func loadHistoricalData() {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        bpiHistory = CoreDataHelper.fetchEntities("BPI", managedObjectContext: moc, predicate: nil, sortDescriptor: sortDescriptor, fetchLimit: 28) as! [BPI]
        
//        var chartSeries:Array<Float> = []
        print("======== BPI HISTORY ============")
        for bpi in bpiHistory {
            print("\(bpi.date) : \(bpi.rate)")
//            chartSeries.append(Float(bpi.rate))
        }
        print("======== BPI HISTORY END ============")
//        
//        let series = ChartSeries(chartSeries)
//        bpiChart.addSeries(series)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notification Handler
    func onCurrentBPIUpdateNotification(notification: NSNotification) {
        if let updatedBPI = notification.object as? BPI {
            currentBPIViewModel = CurrentBPIViewModel(updatedBPI)
            
        }
    }
    
    func onHistoricalBPIUpdateNotification(notification: NSNotification) {
        loadHistoricalData()
    }


}

