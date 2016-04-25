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

enum Mood : Int32 {
    case Energetic = 1
    case Happy = 2
    case Calm = 3
    case Sad = 4
}


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
            
            let valuesList1 = ["xValue" : x , "yValue":y, "zValue": z]
            
            values_REF.updateChildValues(valuesList1)
            
            
            //Interval is in seconds. And now you have got the x, y and z values her
       }
        
    }
    
    @IBAction func stopDetector(sender: UIButton) {
        motionKit.stopAccelerometerUpdates()
        
    }

    func getCurValueFromFirebaseValue(firbaseVal: FDataSnapshot?, countPath: String) -> Int32 {
        var res : Int32 = 0
        if (nil != firbaseVal) {
            let myPrevCountValueDic : NSDictionary? = firbaseVal!.value as? NSDictionary
            if (nil != myPrevCountValueDic) {
                let prevCountVal_ : NSNumber? = myPrevCountValueDic![countPath] as? NSNumber
                if (nil != prevCountVal_) {
                    res = prevCountVal_!.intValue
                }
            }
        }
        return res
    }
    func change(countPath: String, increase: Bool) {
        let countPath_REF = self.backendCrowd.moodValues_REF.childByAppendingPath("count")
        countPath_REF.observeSingleEventOfType(.Value, withBlock: { (prevCountValObj) in
            let prevCountVal : Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: countPath)
            
            let newCountVal : NSNumber = NSNumber(int: prevCountVal + ((increase) ? 1 : -1))
            countPath_REF.updateChildValues([countPath: newCountVal])
        })
    }

    @IBAction func moodButton(sender: UIButton) {
        var uniqueIdentifier: String
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        
        if let identifier = userDefaults.stringForKey("identifier") {
            uniqueIdentifier = identifier
        }
        else {
            uniqueIdentifier = self.backendCrowd.moodValues_REF.childByAutoId().key
            userDefaults.setValue(uniqueIdentifier, forKey: "identifier")
            userDefaults.synchronize()
        }
        
        let moodValue :Mood = Mood(rawValue: Int32(sender.tag))!
        let path = "moodValue" + "/\(uniqueIdentifier)"
        let moodValues_REF = self.backendCrowd.moodValues_REF.childByAppendingPath(path)

        moodValues_REF.observeSingleEventOfType(.Value, withBlock: { (prevMoodValueObj) in
            var prevValue: NSNumber = 0
            if (nil != prevMoodValueObj) {
                let myPrevValueDic : NSDictionary? = prevMoodValueObj.value as? NSDictionary
                if (nil != myPrevValueDic) {
                    prevValue = myPrevValueDic!["moodValue"] as! NSNumber
                }
            }

            let newMoodValNum : NSNumber = NSNumber(int: moodValue.rawValue)
            moodValues_REF.updateChildValues(["moodValue": newMoodValNum])
            if (prevValue != newMoodValNum) {
                // value was updated
                // here we should updated count
               
                if (prevValue.intValue == Mood.Happy.rawValue) {
                    self.change("countHappy", increase: false)
                }
                if (newMoodValNum.intValue == Mood.Happy.rawValue) {
                    self.change("countHappy", increase: true)
                }
                if (prevValue.intValue == Mood.Sad.rawValue) {
                    self.change("countSad", increase: false)
                }
                if (newMoodValNum.intValue == Mood.Sad.rawValue) {
                    self.change("countSad", increase: true)
                }
                if (prevValue.intValue == Mood.Energetic.rawValue) {
                    self.change("countEnergetic", increase: false)
                }
                if (newMoodValNum.intValue == Mood.Energetic.rawValue) {
                    self.change("countEnergetic", increase: true)
                }
                if (prevValue.intValue == Mood.Calm.rawValue) {
                    self.change("countCalm", increase: false)
                }
                if (newMoodValNum.intValue == Mood.Calm.rawValue) {
                    self.change("countCalm", increase: true)
                }
            }
        })
    }
    /*@IBOutlet weak var happyShow: UILabel!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let countPath_REF = self.backendCrowd.moodValues_REF.childByAppendingPath("count")
        countPath_REF.observeEventType(.Value, withBlock: { (prevCountValObj) in
            let cntHappy: Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: "countHappy")
            let cntSad: Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: "countSad")
            let cntEnergetic: Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: "countEnergetic")
            let cntCalm: Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: "countCalm")
            self.happyShow.text = NSString(format: "H: %d S: %d E: %d c: %d", cntHappy, cntSad, cntEnergetic, cntCalm) as String
        })
    }*/
}
