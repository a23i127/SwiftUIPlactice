import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
        users.group(":userID") { user in
            user.get(use: show)
        }
    }

    // GET /users
    func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }

    // POST /users
    func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self)

        // 既に同じGoogle Subのユーザーがいるかチェック（オプション）
        if let existingUser = try await User.query(on: req.db)
            .filter(\.$googleSub == user.googleSub)
            .first()
        {
            return existingUser
        }

        try await user.save(on: req.db)
        return user
    }

    // GET /users/:userID
    func show(req: Request) async throws -> User {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user
    }
}
