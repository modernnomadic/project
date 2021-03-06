//This is where the Firebase backend pathways are defined

import Foundation
import Firebase

class Backend {
    static let backendService = Backend()
    
    private var _BASE_REF = Firebase(url: "\(BASE_URL)")
    private var _motionValues_REF = Firebase(url: "\(BASE_URL)/valuesParent")
    private var _moodValues_REF = Firebase(url: "\(BASE_URL)/moodValue")
    private var _chat_REF = Firebase(url: "\(BASE_URL)/chat")
    
   
    
    var BASE_REF: Firebase {
        return _BASE_REF
    }
    var motionValues_REF: Firebase {
        
        return _motionValues_REF
    }
    var moodValues_REF: Firebase {
        
        return _moodValues_REF
    }
    var CHAT_REF: Firebase{
        return _chat_REF
    }
    
}