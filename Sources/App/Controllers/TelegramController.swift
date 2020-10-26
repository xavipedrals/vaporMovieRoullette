//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 26/10/2020.
//

import Foundation
import TelegramBotSDK
import Jobs

class TelegramController {
    
    var bot: TelegramBot
    var myChat: ChatId
    
    init(token: String) {
        self.bot = TelegramBot(token: token)
        self.myChat = .chat(8930441) // your user id
    }
    
    func sayHello() {
        bot.sendMessageSync(chatId: myChat, text: "Hello master it's \(Date())")
    }
    
    func setupTimer() {
        Jobs.add(interval: .seconds(20)) {
            print("👋 I'm printed every 20 seconds!")
            self.sayHello()
        }
    }
    
}
