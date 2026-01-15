import Fluent

struct CreateComment: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("comments")
            .id()
            .field("post_id", .uuid, .required, .references("posts", "id"))
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("body", .string, .required)
            .field("created_at", .datetime)
            .field("status", .string)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("comments").delete()
    }
}
