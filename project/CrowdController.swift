//
//  ViewController.swift
//  project
//
//  Created by Undraa Khurtsbilegt on 18/04/2016.
//  Copyright © 2016 Amarbayasgalan Batbaatar. All rights reserved.
//

import UIKit
import Foundation
import Firebase



class CrowdController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       /*
        let values_REF = self.backendCrowd.motionValues_REF.childByAppendingPath("values")
        
//        values_REF.observeEventType(.Value, withBlock: { snapshot in
//            print(snapshot.value)
//        }
        
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
                let x = value["xValue"] as! Double
                let y = value["yValue"] as! Double
                let z = value["zValue"] as! Double
                
                sum_x += x
                sum_y += y
                sum_z += z
            })
            
            average_x = sum_x/numberOfValues
            average_y = sum_y/numberOfValues
            average_z = sum_z/numberOfValues
            
            print("x:\(average_x) y:\(average_y)z:\(average_z)")
  
            
            
        })
        // Do any additional setup after loading the view, typically from a nib.
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var getResultX: UILabel!
    
    @IBOutlet weak var getResultY: UILabel!
    
    @IBOutlet weak var getResultZ: UILabel!
    
    let motionKit = MotionKit()
    let backendCrowd = Backend()
    
    @IBAction func invokeDetector(sender: UIButton) {
        
        
        motionKit.getAccelerometerValues(0.1)
        {
            (x, y, z) in
            
            
            
            print(x)
            print(y)
            print(z)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.getResultX.text = "\(x)"
                self.getResultY.text = "\(y)"
                self.getResultZ.text = "\(z)"
            
            })
            
            var uniqueIdentifier: String
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            if let identifier = userDefaults.stringForKey("identifier") {
                uniqueIdentifier = identifier
            }
            else {
                uniqueIdentifier = self.backendCrowd.motionValues_REF.childByAutoId().key
                
                userDefaults.setValue(uniqueIdentifier, forKey: "identifier")
                userDefaults.synchronize()
            }
            
            let path =  "values" + "/\(uniqueIdentifier)"
            let values_REF = self.backendCrowd.motionValues_REF.childByAppendingPath(path)
            
            
            //let values_REFz = values_REF.childByAutoId()
            
            // - valueParents
            //   - device1
            //      - x
            //      - y
            //      - z
            //   - device2
            //      - x
            
            let valuesList1 = ["xValue" : x , "yValue":y, "zValue": z]
            //let valuesList1REF = values_REF.childByAutoId()
            values_REF.updateChildValues(valuesList1)
            
          //  let values_REF1 = self.backendCrowd.motionValues_REF.childByAppendingPath("values2")
          //  let valuesList2 = ["xValue" : x , "yValue":y, "zValue": z]
          //  let valuesList2REF = values_REF.childByAutoId()
          //  valuesList2REF.updateChildValues(valuesList2)
       
            
            //Interval is in seconds. And now you have got the x, y and z values here
        }
        
    }
    @IBAction func stopDetector(sender: UIButton) {
        
        
        motionKit.stopAccelerometerUpdates()
        
    }
}
