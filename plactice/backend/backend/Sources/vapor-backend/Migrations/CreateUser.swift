import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("google_sub", .string, .required)
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("icon_url", .string, .required)
            .field("created_at", .datetime)
            .unique(on: "google_sub")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
