import Fluent
import Vapor

final class Comment: Model, Content, @unchecked Sendable {
    static let schema = "comments"

    enum Status: String, Codable {
        case visible
        case deleted
        case hidden
    }

    @ID()
    var id: UUID?

    @Parent(key: "post_id")
    var post: Post

    @Parent(key: "user_id")
    var user: User

    @Field(key: "body")
    var body: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @OptionalEnum(key: "status")
    var status: Status?

    init() {}

    init(
        id: UUID? = nil, postID: Post.IDValue, userID: User.IDValue, body: String,
        status: Status? = .visible
    ) {
        self.id = id
        self.$post.id = postID
        self.$user.id = userID
        self.body = body
        self.status = status
    }
}
