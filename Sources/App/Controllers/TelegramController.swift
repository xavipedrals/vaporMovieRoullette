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
    let router: Router
    
    init(token: String) {
        self.bot = TelegramBot(token: token)
        self.myChat = .chat(8930441) // your user id
        self.router = Router(bot: bot)
    }
    
    func sayHello() {
        bot.sendMessageSync(chatId: myChat, text: "Hello master it's \(Date())")
    }
    
    func setupTimer() {
//        Jobs.add(interval: .seconds(20)) {
//            print("👋 I'm printed every 20 seconds!")
//            self.sayHello()
//        }
    }
    
    func startListening() {
        router["greet"] = { context in
            guard let from = context.message?.from else { return false }
            context.respondAsync("Hello, \(from.firstName)!")
            return true
        }
        router["randomFact"] = { context in
            guard let from = context.message?.from else { return false }
            let facts = ["Berga no mola", "El Corona no esiste", "El Madrid la chupa", "La raspbi mola", "Ningú vol anar a buscar bolets amb mi"]
            context.respondAsync(facts.randomElement()!)
            return true
        }
        while let update = bot.nextUpdateSync() {
            try? router.process(update: update)
        }
    }

    
}
