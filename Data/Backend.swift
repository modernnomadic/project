
import Foundation
import Firebase

class Backend {
    static let backendService = Backend()
    
    private var _BASE_REF = Firebase(url: "\(BASE_URL)")
    private var _motionValues_REF = Firebase(url: "\(BASE_URL)/valuesParent")
    private var _moodValues_REF = Firebase(url: "\(BASE_URL)/moodValue")

    
    var BASE_REF: Firebase {
        return _BASE_REF
    }
    var motionValues_REF: Firebase {
        
        return _motionValues_REF
    }
    var moodValues_REF: Firebase {
        
        return _moodValues_REF
    }
    
}