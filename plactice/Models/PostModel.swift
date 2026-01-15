import Foundation

struct Post: Identifiable, Decodable {
    let id: UUID
    let title: String
    let body: String
    let createdAt: Date?
    let author: Author

    // VaporのContentはデフォルトでプロパティ名をキーにするため、
    // backendの変数名(createdAt, iconURL)と一致させる必要があります。

    struct Author: Decodable {
        let id: UUID
        let name: String
        let iconURL: String
    }
}

// コメント一覧表示用モデル
struct Comment: Identifiable, Decodable {
    let id: UUID
    let body: String
    let createdAt: Date?
    let user: User  // コメント作成者

    struct User: Decodable {
        let id: UUID
        let name: String
        let iconURL: String
    }
}
