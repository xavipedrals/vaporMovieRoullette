//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 26/10/2020.
//

import Foundation
import TelegramBotSDK
import Vapor

class TelegramController {
    
    static var shared: TelegramController?
    var bot: TelegramBot
    var myChat: ChatId
    let router: TelegramBotSDK.Router
    
    var eventLoop: EventLoop
    
    let updateMoviesId = "updateNetflixMovies"
    let rebootId = "reboot"
    let answerTextId = "fraseBadi"
    let serverStatusId = "serverStatus"
    let weeklyUpdateId = "updateWeeklyNetflixMovies"
    
    let xaviUserId: Int64 = 8930441
    
    init(token: String, eventLoop: EventLoop) {
        self.bot = TelegramBot(token: token)
        self.myChat = .chat(xaviUserId) // your user id
        self.router = Router(bot: bot)
        self.eventLoop = eventLoop
        TelegramController.shared = self
    }
    
    func setupRoutes() {
        setupHelp()
        setupServerStatus()
        setupTextAction()
        setupReboot()
        setupGetWeeklyUpdate()
        startListening()
    }
    
    func sendMessage(text: String) {
        bot.sendMessageSync(chatId: myChat, text: text)
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
            guard let word1 = context.args.scanWord(),
                  word1.count == 8 else {
                context.respondAsync("Can't get movie with id -> \(context.args.scanWord() ?? "")")
                return true
            }
            let sidote = [80092926, 80117552, 80095241, 80192098, 80178404, 80114988, 70297144, 80187302, 80122179, 80136311, 80179831, 80171965, 80113090, 80132738, 80117291, 80159732, 80057883, 80155793, 80156387, 80095532, 80075820, 80105699, 80113612, 80141782, 80063153, 80133187, 80025678, 80108159, 80091742, 80114225, 80057281, 80075595, 80095626, 80041089, 80065146, 80022456, 80074249, 80028732, 80000770, 80002311, 80049714, 80024057, 80075178, 80067942, 80044965, 80025172, 80030346, 80040330, 80049275, 80039394, 80035684, 80025744, 70236561, 80041601, 70155567, 70155589, 70254851, 70136140, 70158329, 70155618, 80002479, 70264888, 70204980, 70140450, 70285368, 70140358, 80003196, 80031039, 80007945, 70302572, 80027563, 70221438, 80025601, 80017537, 70304256, 70258489, 70205672, 80018294, 70273371, 70153385, 70300800, 70213130, 70242311, 80010655, 80021955, 70300626, 70305883, 70178217].compactMap{ String($0) }
            
            
            try? FindLostJob(databaseHelper: DatabaseHelper.shared, eventLoop: self.eventLoop).getDetailsFor(netflixIds: sidote).wait()
            context.respondAsync(word1)
//            context.respondAsync(facts.randomElement()!)
            return true
        }
    }
    
    func setupGetWeeklyUpdate() {
//        router[weeklyUpdateId] = { context in
//            let option = WeeklyUpdateOption() { success in
//                let answer = success
//                    ? "Got the new weekly update ✅"
//                    : "Error when retrieving the new weekly update ❌"
//                context.respondAsync(answer)
//            }
//            option.run()
//            return true
//        }
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
