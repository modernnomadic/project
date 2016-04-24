
//  ViewController.swift
//  project
//
//  Created by Undraa Khurtsbilegt on 18/04/2016.
//  Copyright © 2016 Amarbayasgalan Batbaatar. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

 
    @IBOutlet weak var graphView: GraphView!
    
    let backendGraph = Backend()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        assert(nil != self.graphView)

        let values_REF = self.backendGraph.motionValues_REF.childByAppendingPath("values")

        var data: NSDictionary?
        
        values_REF.observeEventType(.Value, withBlock: { (snapshot) in
            data = snapshot.value as? NSDictionary
            
            var average_x: Double
            var average_y: Double
            var average_z: Double
            
            var sum_x: Double = 0
            var sum_y: Double = 0
            var sum_z: Double = 0
            let numberOfValues = Double((data?.allValues.count)!)
            
            data?.allValues.forEach({ (value) in
                print(value)
                let x1 = value["xValue"] as! Double
                let y2 = value["yValue"] as! Double
                let z3 = value["zValue"] as! Double
                
                sum_x += x1
                sum_y += y2
                sum_z += z3
            })
            
            average_x = sum_x/numberOfValues
            average_y = sum_y/numberOfValues
            average_z = sum_z/numberOfValues
            
            
            assert(nil != self.graphView)
            self.graphView.addX(average_x, y: average_y, z: average_z)
            
            
    
     })
    }
} //*/
