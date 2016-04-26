
import UIKit
import Firebase
import JSQMessagesViewController

class ControllerForChat: JSQMessagesViewController {
    let forChatBackEnd = Backend()
    
    // MARK: Properties
    let rootRef = Firebase(url: "https://mcdj-amarbayasgalan-batbaatar.firebaseio.com/")
    var messageRef: Firebase!
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        setupBubbles()
        messageRef = rootRef.childByAppendingPath("messages")
        
        // No avatars
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView!.textColor = UIColor.whiteColor() // 2
        } else {
            cell.textView!.textColor = UIColor.blackColor() // 3
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func observeMessages() {
        // 1
        let messagesQuery = messageRef.queryLimitedToLast(25)
        // 2
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            // 3
            let id = snapshot.value["senderId"] as! String
            let text = snapshot.value["text"] as! String
            
            // 4
            self.addMessage(id, text: text)
            
            // 5
            self.finishReceivingMessage()
        }
    }

    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "text": text,
            "senderId": senderId
        ]
        itemRef.setValue(messageItem) // 3
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
    }
    
    private func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
}