//
//  MessageController.swift
//  lego-ar-world-app
//
//  Created by Srinjoy Majumdar on 1/1/19.
//  Copyright © 2019 Srinjoy Majumdar. All rights reserved.
//

import Foundation

class MessageManager {
    var viewController: MainViewController
    
    struct Message {
        var text = String()
        var persistent = false
    }

    var messageQueue = Queue<Message>()
    
    var messageTimer: Timer!
    
    init (viewController: MainViewController) {
        self.viewController = viewController
    }

    func queueMessage(_ text: String) {
        let message = Message(text: text, persistent: false)

        messageQueue.enqueue(message)
        if (messageTimer == nil || !messageTimer.isValid) {
            showNextMessage()
        }
    }
    
    func showNextMessage(){
        DispatchQueue.main.async {
            if !self.messageQueue.isEmpty {
                self.viewController.messageBox.text = self.messageQueue.dequeue()?.text
                self.viewController.messageBox.fadeIn()
                self.messageTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updateMessage), userInfo: nil, repeats: false)
            } else {
                self.viewController.messageBox.fadeOut()
                self.viewController.messageBox.text = ""
            }
        }
    }
    
    @objc func updateMessage () {
        messageTimer.invalidate()
        showNextMessage()
    }
}
