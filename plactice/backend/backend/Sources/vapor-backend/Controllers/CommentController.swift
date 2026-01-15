import Fluent
import Vapor

struct CommentController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let comments = routes.grouped("comments")
        // POST /comments/:userID
        comments.post(":userID", use: create)

        comments.group(":commentID") { comment in
            comment.delete(use: delete)
        }

        // 特定のPostに紐づくコメントを取得する場合
        // GET /posts/:postID/comments という設計も一般的ですが、
        // ここでは簡単にフィルタリングする例
        comments.get("post", ":postID", use: indexByPost)
    }

    // POST /comments/:userID
    func create(req: Request) async throws -> Comment {
        // パラメータからuserIDを取得
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid userID parameter")
        }

        let dto = try req.content.decode(CreateCommentDTO.self)

        let comment = Comment(
            postID: dto.postID,
            userID: userID,
            body: dto.body,
            status: .visible
        )

        try await comment.save(on: req.db)
        return comment
    }

    // GET /comments/post/:postID
    func indexByPost(req: Request) async throws -> [Comment] {
        guard let postID = req.parameters.get("postID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return try await Comment.query(on: req.db)
            .filter(\.$post.$id == postID)
            .with(\.$user)  // Userデータを取得
            .sort(\.$createdAt, .ascending)  // 古い順
            .all()
    }

    // DELETE /comments/:commentID
    func delete(req: Request) async throws -> HTTPStatus {
        guard let comment = try await Comment.find(req.parameters.get("commentID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        try await comment.delete(on: req.db)
        return .noContent
    }
}

struct CreateCommentDTO: Content {
    var postID: UUID
    // userIDはURLパラメータから取得するため削除
    var body: String
}
