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
//    app.logger.logLevel = .debug
    app.logger.logLevel = .error
    try app.autoMigrate().wait()
    DatabaseHelper.shared.db = app.db
    
    let controller = TelegramController(token: Environment.get("TELEGRAM_API_TOKEN")!)
    controller.setupRoutes()
    
    try app.queues.use(.redis(url: "redis://127.0.0.1:6379"))
    let dailyJob = DailyJob() {
        print("Daily job finished")
        controller.sendMessage(text: "Finished Daily job successfully")
    }
    app.queues.schedule(dailyJob)
        .daily()
        .at(11, 12)
    
    let biWeeklyJob = WeeklyJob() {
        print("Weekly job finished")
        controller.sendMessage(text: "Finished Weekly job successfully")
    }
    app.queues.schedule(biWeeklyJob)
        .weekly()
        .on(.thursday)
        .at(.noon)
    
    try app.queues.startScheduledJobs()
    try routes(app)
}
