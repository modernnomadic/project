//This piece of code uses MotionKit wrapper https://github.com/MHaroonBaig/MotionKit
//MotionKit wrapper which utilizes CoreMotion framework was modified to be able to get only the accelerometer value.

import Foundation
import CoreMotion

@objc protocol MotionKitDelegate {
    optional  func retrieveAccelerometerValues (x: Double, y:Double, z:Double, absoluteValue: Double)
}


@objc(MotionKit) public class MotionKit :NSObject{
    
    let manager = CMMotionManager()
    var delegate: MotionKitDelegate?
    
    public override init(){
        NSLog("MotionKit has been initialised successfully")
    }
    
    /*
    *  getAccelerometerValues:interval:values:
    *  Discussion:
    *   Starts accelerometer updates, providing data to the given handler through the given queue.
    */
    public func getAccelerometerValues (interval: NSTimeInterval = 0.1, values: ((x: Double, y: Double, z: Double) -> ())? ){
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.accelerometerAvailable {
            manager.accelerometerUpdateInterval = interval
            manager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: {
                (data, error) in
                
                if let isError = error {
                    NSLog("Error: %@", isError)
                }
                valX = data!.acceleration.x
                valY = data!.acceleration.y
                valZ = data!.acceleration.z
                
                if values != nil{
                    values!(x: valX,y: valY,z: valZ)
                }
                let absoluteVal = sqrt(valX * valX + valY * valY + valZ * valZ)
                self.delegate?.retrieveAccelerometerValues!(valX, y: valY, z: valZ, absoluteValue: absoluteVal)
            })
        } else {
            NSLog("The Accelerometer is not available")
        }
    }

    public func stopAccelerometerUpdates(){
        self.manager.stopAccelerometerUpdates()
        NSLog("Accelaration Updates Status - Stopped")
    }
}