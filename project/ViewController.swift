
//  ViewController.swift
//  project
//
//  Copyright © 2016 Amarbayasgalan Batbaatar. All rights reserved.
//
//This is the view controller for DJ interface. It retrieves the data from Firebase backend which the CrowdController has put in and shows the received data through pie chart(Crowd Desire) and motion graph(Crow Motion).

//For the piechart (setChart) I modified a tutorial at http://www.appcoda.com/ios-charts-api-tutorial/ to able to receive the incoming data from the Firebase backend
//For the motion graph I adapted and modified https://github.com/kentliau/MotionGraphSwift to push only the accelerometer method. It is located in Supported folder under Graphview.

import UIKit
import Firebase
import Charts


class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var graphView: GraphView!
    
    let backendGraph = Backend()
    
    // function that gets the total current mood value from the Firebase backend which the users has inputed in CrowdController
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
    // function that gets the value from above function getCurValueFromFirebaseValue and sends the data to setChart
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let countPath_REF = self.backendGraph.moodValues_REF.childByAppendingPath("count")
        countPath_REF.observeEventType(.Value, withBlock: { (prevCountValObj) in
            let cntHappy: Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: "countHappy")
            let cntSad: Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: "countSad")
            let cntEnergetic: Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: "countEnergetic")
            let cntCalm: Int32 = self.getCurValueFromFirebaseValue(prevCountValObj, countPath: "countCalm")
            
            let moodState = ["Happy", "Sad", "Energetic", "Calm"]
            let givenMood = [Double(cntHappy), Double(cntSad), Double(cntEnergetic), Double(cntCalm)]
            self.setChart(moodState, values: givenMood)
            
        })
    }
    //this function setChart builds the structure of the pie chart using Charts framework
    func setChart(givenPoints: [String], values: [Double]) {
        pieChartView.noDataText = "Crowd hasn't chosen their desired moot yet :)"
    
        var givenEntries: [ChartDataEntry] = []
        
        for i in 0..<givenPoints.count {
            let givenEntry = ChartDataEntry(value: values[i], xIndex: i)
            givenEntries.append(givenEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: givenEntries, label: "")
        let pieChartData = PieChartData(xVals: givenPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        pieChartView.descriptionText = ""
        pieChartView.backgroundColor = UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1)
        
        var colors: [UIColor] = []
        
        for i in 0..<givenPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
           
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
        
    }
    //this function receives all the motion data collected from the users in the Firebase backend and gets the average to display in the motion graph and finally pushes the data processed to the GraphView where the motion graph is built
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

}
