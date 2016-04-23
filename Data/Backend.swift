
import Foundation
import Firebase

class Backend {
    static let backendService = Backend()
    
    private var _BASE_REF = Firebase(url: "\(BASE_URL)")
    private var _motionValues_REF = Firebase(url: "\(BASE_URL)/valuesParent")
    private var _JOKE_REF = Firebase(url: "\(BASE_URL)/jokes")
    
    var BASE_REF: Firebase {
        return _BASE_REF
    }
    
    var motionValues_REF: Firebase {
        
        
        
        
        
        
        return _motionValues_REF
    }
    
    var CURRENT_USER_REF: Firebase {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        
        let currentUser = Firebase(url: "\(BASE_REF)").childByAppendingPath("users").childByAppendingPath(userID)
        
        return currentUser!
    }
    
}