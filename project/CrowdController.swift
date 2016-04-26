//
//  ViewController.swift
//  project
//
//  Created by Undraa Khurtsbilegt on 18/04/2016.
//  Copyright © 2016 Amarbayasgalan Batbaatar. All rights reserved.
//
//This is the View controller for Crowd interface. From this CrowdController class all the datas that a users generate will be stored to Firebase backend. From there other classes will be able to retrieve the data by calling their unique paths.
//The interface consists of 2 main properties.
//1. Desired Mood that gets the desired mood from the users by tapping the desired mood (Happy, Sad, Calm and Energetic). As user can desire only one mood at a time I have created a unique algorithm that sends only the current desire. When a user wants to desire other mood it then automatically sends the signal to the backend saying disregard the previous mood and set it to new mood.
//2. Motion Detector which activates the collecting of user accelerometer data when pressed Run(mobile phone shaking icon). It can then be stopped by pressing the Off(Zzz sleeping icon). Also it shows your accelerometer values - I included this with a tought that user might want to see the motion they create.
//  2.1 Motion Detector uses MotionKit wrapper to collect the accelerometer data easily. MotionKit is located in the Supported folder.

import UIKit
import Foundation
import Firebase

//creating Mood group and assigning them a identifier
enum Mood : Int32 {
    case Energetic = 1
    case Happy = 2
    case Calm = 3
    case Sad = 4
}


class CrowdController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBOutlet weak var getResultX: UILabel!
    
    @IBOutlet weak var getResultY: UILabel!
    
    @IBOutlet weak var getResultZ: UILabel!
    
    let motionKit = MotionKit()
    let backendCrowd = Backend()
    
    // this function invokeDetector is activated when the user presses Run(mobile phone shaking icon). It then initialises MotionKit - allowing me to get the accelerometer value by calling getAccelerometerValues(your-desired-interval).
    // also, as this app will be used on multiple devices at the same time, I have developed a code to assign a unique key for each individual device that are sending accelerometer value. This is essential because we don't want each devices to overwrite each other's transmitting data.

    @IBAction func invokeDetector(sender: UIButton) {
        
        
        motionKit.getAccelerometerValues(0.1)
        {
            (x, y, z) in

            dispatch_async(dispatch_get_main_queue(), {
                self.getResultX.text = "\(x)"
                self.getResultY.text = "\(y)"
                self.getResultZ.text = "\(z)"
                
            })
            //creating a unique identifier for each individual device.
            var uniqueIdentifier: String
            let userDefaults = NSUserDefaults.standardUserDefaults()
            //identifies teh current device and set their identifier key
            if let identifier = userDefaults.stringForKey("identifier") {
                uniqueIdentifier = identifier
            }
            //if its a new device connecting, create a new key for them and store the detail in the Firebase backend
            else {
                uniqueIdentifier = self.backendCrowd.motionValues_REF.childByAutoId().key
                
                userDefaults.setValue(uniqueIdentifier, forKey: "identifier")
                userDefaults.synchronize()
            }
            
            let path =  "values" + "/\(uniqueIdentifier)"
            let values_REF = self.backendCrowd.motionValues_REF.childByAppendingPath(path)
            
            let valuesList1 = ["xValue" : x , "yValue":y, "zValue": z]
            
            values_REF.updateChildValues(valuesList1)
            
       }
        
    }
    //When user presses Off(Zzz sleeping icon), stops the updates from the MotionKit to retrieve accelerometer values.
    @IBAction func stopDetector(sender: UIButton) {
        motionKit.stopAccelerometerUpdates()
        
    }
    //function that gets the total current mood value from the Firebase backend which the users
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
    //function 'change' is an algorithm that when user enter new desired mood, it increases the desired moood by 1 and decreases the previous mood by -1
    func change(countPath: String, increase: Bool) {
        let countPath_REF = self.backendCrowd.moodValues_REF.childByAppendingPath("count")
        countPath_REF.observeSingleEventOfType(.Value, withBlock: { (prevCountValObj) in
            let prevCountVal : Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: countPath)
            
            let newCountVal : NSNumber = NSNumber(int: prevCountVal + ((increase) ? 1 : -1))
            countPath_REF.updateChildValues([countPath: newCountVal])
        })
    }
    // function that controls mood buttons on the CrowdController interface. All 4 button is connected to this single button action. It then filters which button is pressed through enum Mood that we created earlier by receiving their identifier. As same with the function invokeDetector, It also uniquely filters each devices state of the mood.
    
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
        //giving unique identity to particilar device and setting their state of the mood.
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
            // changing the state of the moods.
            let newMoodValNum : NSNumber = NSNumber(int: moodValue.rawValue)
            moodValues_REF.updateChildValues(["moodValue": newMoodValNum])
            if (prevValue != newMoodValNum) {
                
                // value was updated.
             
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
}
