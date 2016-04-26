//
//  LoginForChat.swift
//  project
//
//  Created by Undraa Khurtsbilegt on 25/04/2016.
//  Copyright © 2016 Amarbayasgalan Batbaatar. All rights reserved.
//

//Modified from tutorial at https://www.raywenderlich.com/122148/firebase-tutorial-real-time-chat


//Allows the user to connect and create ID to the chat throught Firebase backend

import Foundation
import Firebase



class LoginForChat: UIViewController {
    //opens a channel to my firebase database
        var ref: Firebase! // 1
    //calls my backend class to establish connection
    let backendChat = Backend()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        ref = Firebase(url: "https://mcdj-amarbayasgalan-batbaatar.firebaseio.com")
    }
    
    @IBAction func loginTouched(sender: AnyObject) {
        
        //when the loginTouched button is pressed it automatically creates a waypoint to the ControllerForChat through segue
        //thats going to identify with "LoginToChat"
        let loginPath_REF = backendChat.CHAT_REF
        loginPath_REF.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error != nil { print(error.description); return }
            self.performSegueWithIdentifier("LoginToChat", sender: nil)
            
            }
   }
    //prepares the segue when loginTouched button is pressed. It authenticates a device uniquely with their senderId's
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navigateV = segue.destinationViewController as! UINavigationController
        let chatNavigate = navigateV.viewControllers.first as! ControllerForChat
        chatNavigate.senderId = ref.authData.uid
        chatNavigate.senderDisplayName = ""
        
       
    }
}