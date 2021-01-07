import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(hostname: "localhost", username: "vapor", password: "raspbi-vapor", database: "vapor"), as: .psql)
    app.migrations.add(CreateMoviesSchema())
    app.logger.logLevel = .debug
    try app.autoMigrate().wait()
    DatabaseHelper.shared.db = app.db
    try routes(app)
}
