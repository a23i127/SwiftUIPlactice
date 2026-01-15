import Vapor

// Domain-aligned controller for simple health/root and greeting routes
struct HelloController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        // root
        routes.get { req async in
            "It works!"
        }

        // greeting
        routes.get("hello") { req async -> String in
            "Hello, world!"
        }
    }
}
