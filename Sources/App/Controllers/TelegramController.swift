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
            let sidote = [
                81164143, 81062828, 80190519,
                81183491, 80237329, 80992788, 80237347, 80997687, 81160763, 81054827,
                80201590, 80117557, 81167137, 81167101, 81196539, 81224868,
                81037848, 80213020, 81221644, 80989919, 80241410, 81221302, 80987516,
                80240027, 81019391, 80213588, 81075536, 81083590, 80236118, 81055408,
                81172267, 81194523, 81193313, 81094391, 80990849, 80997965, 81018979,
                80156799, 80216180, 81169145, 80244846, 80241539, 80222157, 81011957,
                80238391, 80217594, 80242491, 81034946, 81142595, 81200229, 80201488,
                80218819, 80241387, 80227818, 81166978, 81167029, 81169914,
                80197462, 81086462, 80217627, 80178724, 80208910,
                80222326, 81167011, 81192594, 81193616, 80176234, 81191500, 80216665,
                80215730, 80117803, 80217066, 80209609, 81166946, 80188730, 81167083,
                80225885, 80218107, 80220715, 80241248, 81095101, 81020518, 80184771,
                81020513, 81020523, 80216172, 81000389, 81144925, 81154956, 80219119,
                81174992, 70178604, 81069393, 80217779, 80211572, 81098586, 80178151,
                81170092, 80226089, 80204364, 80203254, 80168068, 81106517,
                80201543, 80205594, 81078331, 81026915, 81040407, 80195357, 80223113,
                81002933, 80243216, 81094271, 80063867, 80217315, 80239462, 80230293,
                80245353, 80992228, 80210294, 80996338, 80215147, 80234451, 81153751,
                80211648, 81072109, 81099997, 70157266, 80245117, 80183051, 80209013,
                81070963, 81027195, 80230561, 80238711, 81006334, 80211563, 80217946,
                80218448, 80233258, 80197889, 81094069, 80213643, 81092192, 80999455,
                80197989, 80216756, 81077044, 81016914, 81104372, 81087762, 80994596,
                80225312, 80198137, 80244996, 80210361, 80986854, 80198950, 81026700,
                80987458, 80211621, 80211492, 81044884, 80198988, 80227574, 80992137,
                80211703, 80241474, 81087764, 80231373, 80235932, 81025019, 80992232,
                80223793, 80230265, 80189632, 80208298, 81002451, 80194956, 80124723,
                80212481, 81033727, 80238357, 80202258, 80222770, 81059451, 80220541,
                80186863, 81045308, 80241855, 80241001, 81002145, 80211627, 80205595,
                81041414, 80991879, 80145141, 80180171, 80226612, 80144442, 80167821,
                80210995, 81021294, 80992787, 80198991, 81008236, 80209379, 80240277,
                80194558, 80211991, 80107989, 81033645, 81023023, 80179784, 80172145,
                80207124, 80200596, 80166467, 81031262, 80191239, 80187030, 80189829,
                80221787, 80195198, 80190086, 80189522, 81019894, 81025403, 80200027,
                81004280, 80211634, 80205593, 80221207, 80191074, 81002951, 81042804,
                80216094, 80180600, 80201866, 80987095, 80179762, 80208213, 81016857,
                80227995, 80215086, 80241947, 80987753, 80223989, 80147920, 80991329,
                80211465, 80207486, 81003997, 80161728, 80200942, 80220650, 80198511,
                80214792, 80150290, 80124522, 80157073, 81003648, 80240397, 80220035,
                80191522, 80184405, 80245450, 80158516, 80243728, 80190510, 80095697,
                80225020, 80160935, 80245299, 81004322, 80179905, 80988815, 80202283,
                80215500, 80198459, 80230018, 81003033, 80212251, 80997339, 81005504,
                80179782, 80173174, 80177342, 81011059, 80097225, 80240691, 80178941,
                80195811, 80211136, 80204451, 80188605, 80177416, 80158515, 80192577,
                80147919, 80233441, 80224294, 80184379, 80201500, 80996791, 80154610,
                80193475, 80192734, 80184682, 80198635, 80104198, 80218962, 80986797,
                80178943, 80174145, 80191369, 80208373, 80987906, 80206395, 80174285,
                80184068, 80185171, 80161848, 80174617, 80097594, 80156688, 80117555,
                80170368, 80138915, 80161335, 80211384, 80211576, 80117551, 80157137,
                80227798, 80176771, 80141960, 80115338, 80178687, 80180373, 80221166,
                80209096, 80228291, 80146284, 80174974, 70296735, 80194813, 80174917,
                80212301, 80190279, 80059446, 80216376, 80216651, 80221261, 80211787,
                80198545, 80117554, 80171561, 80095988, 80174280, 80171452, 80175802,
                80186090, 80119411, 80215076, 80214115, 80214013, 80195522, 80184569,
                80183199, 80176076, 80124711, 80186459, 80208337, 80179394, 80141270,
                80195828, 80202539, 80181555, 80117038, 80108373, 80196221, 80095435,
                80117902, 80105933, 80189183, 80117694, 80002566, 80180182, 80191680,
                80063599, 80117800, 80057918, 80130521, 80192842, 80117485, 80180849,
                80118532, 80095411, 80114988, 80134695, 80177986, 80183878, 80178427,
                80133042, 80171004, 80178564, 80124091, 80174364, 80107369, 80115432,
                80095698, 80100929, 80154638, 80176866, 80115676, 80176866, 80178543,
                80170688, 80165487, 80117470, 80049928, 80066429, 80002612, 80081170,
                80140955, 80153272, 80095299, 80162994, 80164216, 80057749, 80095815,
                80133311, 80099656, 80050008, 80156387, 80121349, 80044950, 80104983,
                80039972, 80128756, 80091880, 80077417, 80057171, 80091245, 80109535,
                80135640, 80109415, 80074220, 80123729, 80127464, 80007778, 80113201,
                80094260, 80116922, 80138030, 80108495, 80095900, 80126646, 80002537,
                80113647, 80095699, 80133117, 80078197, 80057611, 80063705, 80094728,
                80113541, 70304246, 80097771, 80087548, 80103006, 80026224, 80046193,
                80105452, 80049872, 80037278, 80045820, 80106136, 80094273, 80063989,
                80101401, 80077977, 80095866, 80046249, 70201870, 80091341, 80062112,
                80058427, 80051137, 80026506, 80073486, 80043576, 80094386, 80062047,
                80081705, 80052714, 80082160, 80028732, 80074503, 80002311, 80049065,
                80046348, 80052669, 80027158, 80059047, 80027159, 80053653, 80011206,
                80067618, 70217377, 80063658, 80060413, 80040330, 80020542, 70250398,
                80039813, 80036140, 80039394, 70177040, 80022632, 70205687, 70205688,
                70289901, 70157460, 70158331, 70297439, 70305043, 70177034, 70158332,
                80002999, 70180293, 70158330, 70286808, 70143843, 70172485, 80031039,
                70288470, 80008434, 70184128, 70142436, 80025384, 70272742, 70221438,
                70242310, 70252973, 70234439, 70234440, 70258489, 70242629, 70271773,
                70177033, 70264612, 70213130, 70264616, 70294800, 80010655, 70304252,
                70304245, 70206898, 70218316, 70286809, 70302573, 70302614, 70281343,
                70300626, 70180051, 80018988, 80018987, 70305883,
                //Conflict movies below
                80155793,
                80041601,
                81267787,
                81069541,
                80223040,
                81152644,
                81243992,
                80212986,
                81220429,
                80996601,
                81038696,
                81038022,
                81061828,
                81200716,
                81219073
            ].compactMap{ String($0) }
            do {
                try FindLostJob(databaseHelper: DatabaseHelper.shared, eventLoop: self.eventLoop).getDetailsFor(netflixIds: sidote).wait()
                context.respondAsync(word1)
            } catch {
                context.respondAsync(error.localizedDescription)
            }
            
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
