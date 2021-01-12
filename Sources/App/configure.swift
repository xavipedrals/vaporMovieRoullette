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
    app.migrations.add(CreateSidoteSchema())
//    app.logger.logLevel = .debug
    app.logger.logLevel = .error
    try app.autoMigrate().wait()
    DatabaseHelper.shared.db = app.db
    try app.queues.use(.redis(url: "redis://127.0.0.1:6379"))
    app.queues.schedule(DailyJob(completion: {
        print("Feina feta")
    }))
        .daily()
        .at(9, 25)
    try app.queues.startScheduledJobs()
    try routes(app)
}
