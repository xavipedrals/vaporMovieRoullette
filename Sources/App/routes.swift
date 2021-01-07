import Vapor

func routes(_ app: Application) throws {
    let controller = TelegramController(token: Environment.get("TELEGRAM_API_TOKEN")!)
//    controller.setupTimer()
    controller.setupRoutes()
    
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
}
