//
//  LoginForChat.swift
//  project
//
//  Created by Undraa Khurtsbilegt on 25/04/2016.
//  Copyright © 2016 Amarbayasgalan Batbaatar. All rights reserved.
//

import Foundation
import Firebase


class LoginForChat: UIViewController {
    
    // MARK: Properties
    var ref: Firebase! // 1
    let backendChat = Backend()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        ref = Firebase(url: "https://mcdj-amarbayasgalan-batbaatar.firebaseio.com")
    }
    
    @IBAction func loginTouched(sender: AnyObject) {
        
        let loginPath_REF = backendChat.CHAT_REF
        loginPath_REF.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error != nil { print(error.description); return }
            self.performSegueWithIdentifier("LoginToChat", sender: nil)
            
            }
   }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navigateV = segue.destinationViewController as! UINavigationController
        let chatNavigate = navigateV.viewControllers.first as! ControllerForChat
        chatNavigate.senderId = ref.authData.uid
        chatNavigate.senderDisplayName = ""
        
       
    }
}