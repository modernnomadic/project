
//Modified from tutorial at https://www.raywenderlich.com/122148/firebase-tutorial-real-time-chat


//Using JSQMessegesViewController framework displays the realtime chat interface. It takes the senderID generated from LoginForChat and stores the messeges the user has entered. It then allows other users who are also connected to the chat to be able to receive messages by connecting to the Firebase backend.

import UIKit
import Firebase
import JSQMessagesViewController


class ControllerForChat: JSQMessagesViewController {
    let forChatBackEnd = Backend()
    
    //creating a waypoint the Firebase backend
    let rootRef = Firebase(url: "https://mcdj-amarbayasgalan-batbaatar.firebaseio.com/")
    var messageRef: Firebase!
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    //sets customized control over what the chat can show or not. In this case I modified the code so that it does not allow useres to have avatars and removed a optionality of attaching documents(images) to the chat.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        setupBubbles()
        messageRef = rootRef.childByAppendingPath("messages")
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
      
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    //creates an ordered collection of messages to the interface using NSIndexPath
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
     // View of the chat interface which displays the messages you have written and received and puts them in bubble by calling setupBubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    //allows to present the content of a message data whithin the chat interface
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    // normally JSQMessagesViewController allows each user to have avatar but in my case, as the chat is anonymous it is set to nil
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    //listens from the Firebase backend for receiving messages.
    private func observeMessages() {
 
        let messagesQuery = messageRef.queryLimitedToLast(25)
  
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in

            let id = snapshot.value["senderId"] as! String
            let text = snapshot.value["text"] as! String
            self.addMessage(id, text: text)
            self.finishReceivingMessage()
        }
    }
    //allows you to add message using JSQMessage with users ID, display is set to blank for the purpose of anonymous group chat.
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    //send button on the chat screen that initiates the message sending process.
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "text": text,
            "senderId": senderId
        ]
        itemRef.setValue(messageItem)
        
       
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
      
        finishSendingMessage()
    }
    //creating bubble wrap around the incoming and outgoing messages.
    private func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
}