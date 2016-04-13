//
//  BPIViewController.swift
//  BPI
//
//  Created by Greg Williams on 4/12/16.
//  Copyright © 2016 Greg Williams. All rights reserved.
//

import UIKit
import CoreData

class BPIViewController: UIViewController, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {
    
    @IBOutlet weak var currentBPILabel: UILabel!
    @IBOutlet weak var lastUpdatedAtLabel: UILabel!
    @IBOutlet weak var bpiLineGraph: BEMSimpleLineGraphView!

    var currentBPIViewModel:CurrentBPIViewModel? {
        didSet {
            currentBPILabel.text = currentBPIViewModel!.bpiRate
            lastUpdatedAtLabel.text = currentBPIViewModel!.bpiDate
        }
    }
    
    var bpiCollectionViewModel:BPICollectionViewViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentBPIViewModel = CurrentBPIViewModel()
        bpiCollectionViewModel = BPICollectionViewModel()
        bpiCollectionViewModel!.loadCollectionData() // load initial historical data
        
        bpiLineGraph.delegate = self
        bpiLineGraph.dataSource = self
        bpiLineGraph.enablePopUpReport = true
        bpiLineGraph.enableTouchReport = true
        bpiLineGraph.autoScaleYAxis = true
        bpiLineGraph.colorXaxisLabel = UIColor.whiteColor()
        bpiLineGraph.colorYaxisLabel = UIColor.whiteColor()
        bpiLineGraph.formatStringForValues = "%.3f"
        bpiLineGraph.animationGraphEntranceTime = 0
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onCurrentBPIUpdateNotification:",
            name: CurrentBPIUpdateNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onHistoricalBPIUpdateNotification:",
            name: HistoricalBPIUpdateNotification,
            object: nil)

        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: BEMSimpleLineGraph Delegate / Data Source Methods
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return (bpiCollectionViewModel?.bpiCount)!
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        let bpi = bpiCollectionViewModel?.bpiHistory[index]
        return CGFloat(bpi!.rate)
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String {
        let bpi = bpiCollectionViewModel?.bpiHistory[index]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let date = dateFormatter.stringFromDate(bpi!.date)
        return date
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, alwaysDisplayPopUpAtIndex index: CGFloat) -> Bool {
        return true
    }
    
    func popUpPrefixForlineGraph(graph: BEMSimpleLineGraphView) -> String {
        return "€"
    }
    
    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return 6
    }
    
    func numberOfYAxisLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return 2
    }
    
    // MARK: Notification Handler
    func onCurrentBPIUpdateNotification(notification: NSNotification) {
        if let updatedBPI = notification.object as? BPI {
            currentBPIViewModel = CurrentBPIViewModel(updatedBPI)
        }
    }
    
    func onHistoricalBPIUpdateNotification(notification: NSNotification) {
        bpiCollectionViewModel.loadCollectionData()
        self.bpiLineGraph.reloadGraph()
    }
}

