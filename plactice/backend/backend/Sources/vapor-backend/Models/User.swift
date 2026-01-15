import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID()
    var id: UUID?

    @Field(key: "google_sub")
    var googleSub: String

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "icon_url")
    var iconURL: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Children(for: \.$author)
    var posts: [Post]

    @Children(for: \.$user) // 修正: Commentモデルのプロパティ名変更に合わせて \.$author から \.$user へ
    var comments: [Comment]

    init() {}

    init(id: UUID? = nil, googleSub: String, name: String, email: String, iconURL: String) {
        self.id = id
        self.googleSub = googleSub
        self.name = name
        self.email = email
        self.iconURL = iconURL
    }
}
