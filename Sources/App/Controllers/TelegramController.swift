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
    
    let updateMoviesId = "updateNetflixMovies"
    let rebootId = "reboot"
    let answerTextId = "fraseBadi"
    let serverStatusId = "serverStatus"
    let weeklyUpdateId = "updateWeeklyNetflixMovies"
    
    let xaviUserId: Int64 = 8930441
    
    init(token: String) {
        self.bot = TelegramBot(token: token)
        self.myChat = .chat(xaviUserId) // your user id
        self.router = Router(bot: bot)
    }
    
    func setupRoutes() {
        setupHelp()
        setupServerStatus()
        setupTextAction()
        setupReboot()
        setupGetWeeklyUpdate()
        startListening()
    }
    
    func setupHelp() {
        router["help"] = { context in
            let actions = """
                /\(self.serverStatusId) -> Prints server info (temperature)
                /\(self.updateMoviesId) -> Updates Netflix movies
                /\(self.rebootId) -> Reboot the server (only admin)
                /\(self.answerTextId) -> Answers one of Badi's statements
            """
            context.respondAsync(actions)
            return true
        }
    }
    
    func setupServerStatus() {
        router[serverStatusId] = { context in
            let info = self.shell("landscape-sysinfo")
            context.respondAsync(info)
            return true
        }
    }
    
    func setupReboot() {
        router[rebootId] = { context in
            guard let fromId = context.fromId,
                  self.isAdmin(id: fromId) else {
                context.respondAsync("You are not my master, I will not reboot ❌")
                return false
            }
            context.respondAsync("I will now reboot the raspbi, please wait 🙇🏻‍♂️") { _,_  in
                _ = self.shell("sudo reboot")
            }
            return true
        }
    }

    func setupTextAction() {
        router[answerTextId] = { context in
            let facts = [
                "Si les putes no maduressin jo no seria un bon préssec",
                "Adadada dedede Ferrero Rocher",
                "A partir d'ara dogueu-me Don Pajote",
                "Vaig tard perquè estava rentant els plats",
                "Aquest estiu anem als karts"
            ]
            context.respondAsync(facts.randomElement()!)
//            let caca = CCurlHelper()
//            caca.sida()
//            let opt = WeeklyUpdateOption()
            return true
        }
    }
    
    func setupGetWeeklyUpdate() {
        router[weeklyUpdateId] = { context in
            let option = WeeklyUpdateOption() { success in
                let answer = success
                    ? "Got the new weekly update ✅"
                    : "Error when retrieving the new weekly update ❌"
                context.respondAsync(answer)
            }
            option.run()
            return true
        }
    }
    
    func startListening() {
        while let update = bot.nextUpdateSync() {
            _ = try? router.process(update: update)
        }
    }
    
    func isAdmin(id: Int64) -> Bool {
        return id == xaviUserId
    }
    
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
