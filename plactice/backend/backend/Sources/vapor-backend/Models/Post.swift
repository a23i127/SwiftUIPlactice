import Fluent
import Vapor

final class Post: Model, Content, @unchecked Sendable {
    static let schema = "posts"

    enum Visibility: String, Codable {
        case `public`
        case unlisted
    }

    @ID()
    var id: UUID?

    @Parent(key: "author_id")
    var author: User

    @Field(key: "title")
    var title: String

    @Field(key: "body")
    var body: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @OptionalEnum(key: "visibility")
    var visibility: Visibility?

    @Children(for: \.$post)
    var comments: [Comment]

    init() {}

    init(
        id: UUID? = nil, authorID: User.IDValue, title: String, body: String,
        visibility: Visibility? = .public
    ) {
        self.id = id
        self.$author.id = authorID
        self.title = title
        self.body = body
        self.visibility = visibility
    }
}
