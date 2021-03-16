import Vapor
import QueuesRedisDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(hostname: "localhost", username: "vapor", password: "raspbi-vapor", database: "vapor"), as: .psql)
    app.migrations.add(CreateMoviesSchema())
    app.migrations.add(UpdateMoviesSchema())
    app.migrations.add(CreateNetflixCountryOperationSchema())
    app.migrations.add(CreateNetflixNotFoundSchema())
//    app.logger.logLevel = .debug
    app.logger.logLevel = .error
    try app.autoMigrate().wait()
    DatabaseHelper.shared.db = app.db
    
    try app.queues.use(.redis(url: "redis://127.0.0.1:6379"))

    let dailyJob = DailyJobFuture()
    app.queues.schedule(dailyJob)
        .daily()
        .at(09, 28)
    
//    let weeklyJob = WeeklyJob() {
//        print("Weekly job finished")
//        TelegramController.shared?.sendMessage(text: "Finished Weekly job successfully")
//    }
//    app.queues.schedule(weeklyJob)
//        .weekly()
//        .on(.friday)
//        .at(.noon)
    
    try app.queues.startScheduledJobs()
    
//    let telegramEventLoop = app.eventLoopGroup.next()
//    let controller = TelegramController(token: Environment.get("TELEGRAM_API_TOKEN")!, eventLoop: telegramEventLoop)
//    controller.setupRoutes()
    try routes(app)
}
