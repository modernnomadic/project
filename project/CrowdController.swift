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
        
        
        // Do any additional setup after loading the view, typically from a nib.
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
        
        
        motionKit.getAccelerometerValues(1.0)
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
            
            let values_REF = self.backendCrowd.motionValues_REF.childByAppendingPath("values")
            //let values_REFz = values_REF.childByAutoId()
            
            let valuesList1 = ["xValue" : x , "yValue":y, "zValue": z]
            //let valuesList1REF = values_REF.childByAutoId()
            values_REF.updateChildValues(valuesList1)
            
          //   let values_REF1 = self.backendCrowd.motionValues_REF.childByAppendingPath("values2")
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
