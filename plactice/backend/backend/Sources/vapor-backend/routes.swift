import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: HelloController())
    try app.register(collection: UserController())
    try app.register(collection: PostController())
    try app.register(collection: CommentController())
    // CommentUserControllerは削除
}
