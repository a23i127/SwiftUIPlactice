import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let dbConfig = DatabaseConfigurationFactory.postgres(
        configuration: .init(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_DB") ?? "vapor_database",
            tls: .disable
        )
    )
    app.databases.use(dbConfig, as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreatePost())
    app.migrations.add(CreateComment())

    try await app.autoMigrate()

    // register routes
    try routes(app)

    // Register additional controllers here in the future
}
