import Fluent
import Vapor

struct PostController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        posts.get(use: index)
        posts.post(use: create)
        posts.group(":postID") { post in
            post.get(use: show)
            post.delete(use: delete)
        }
    }

    // GET /posts
    func index(req: Request) async throws -> [Post] {
        try await Post.query(on: req.db)
            .with(\.$author)  // 投稿者情報も含める
            .sort(\.$createdAt, .descending)  // 新しい順
            .all()
    }

    // POST /posts
    func create(req: Request) async throws -> Post {
        let postDTO = try req.content.decode(CreatePostDTO.self)

        let post = Post(
            authorID: postDTO.authorID,
            title: postDTO.title,
            body: postDTO.body,
            visibility: postDTO.visibility
        )

        try await post.save(on: req.db)
        return post
    }

    // GET /posts/:postID
    func show(req: Request) async throws -> Post {
        guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return post
    }

    // DELETE /posts/:postID
    func delete(req: Request) async throws -> HTTPStatus {
        guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await post.delete(on: req.db)
        return .noContent
    }
}

// クライアントから受け取るデータ構造
struct CreatePostDTO: Content {
    var authorID: UUID
    var title: String
    var body: String
    var visibility: Post.Visibility?
}
