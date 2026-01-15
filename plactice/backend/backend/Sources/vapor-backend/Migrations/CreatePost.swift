import Fluent

struct CreatePost: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("posts")
            .id()
            .field("author_id", .uuid, .required, .references("users", "id"))
            .field("title", .string, .required)
            .field("body", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("visibility", .string)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("posts").delete()
    }
}
