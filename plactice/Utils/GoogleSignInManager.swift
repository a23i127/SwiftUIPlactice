import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

// サーバーへ送るデータの形
struct CreateUserRequest: Encodable {
    let googleSub: String
    let name: String
    let email: String
    let iconURL: String
}

// サーバーから返ってくるデータの形（IDのみ抽出）
struct BackendUserResponse: Decodable {
    let id: UUID
}

final class GoogleSignInManager: ObservableObject {

    @Published var currentUser: GIDGoogleUser?
    @Published var backendUserID: UUID? // バックエンドのUserテーブルのID
    @Published var errorMessage: String?

    // ★ APIのURL (実機の場合はMacのIPアドレスを指定)
    private let backendURL = "http://192.168.100.50:8080/users"

    /// Googleサインイン処理を開始します。
    @MainActor
    func signIn() async {
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: await MainActor.run {
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?
                        .windows
                        .first?
                        .rootViewController
                }!)
            self.currentUser = result.user
            self.errorMessage = nil

            // ★ ログイン成功後、サーバーにユーザー情報を送信
            try await registerUserToBackend(user: result.user)
            print("✅ バックエンドへのユーザー登録完了")
        } catch {
            self.errorMessage = "サインインでエラーが発生しました: \(error.localizedDescription)"
            print(self.errorMessage!)
        }
    }

    /// Googleサインアウト処理を実行します。
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.currentUser = nil
        self.backendUserID = nil
        self.errorMessage = nil
    }

    // ★ バックエンドへのPOST処理
    private func registerUserToBackend(user: GIDGoogleUser) async throws {
        // 必要な情報が揃っているか確認
        guard let userID = user.userID,
            let profile = user.profile
        else {
            print("❌ ユーザー情報が不足しています")
            return
        }

        // リクエストボディを作成（200pxサイズのアイコンを取得）
        let requestBody = CreateUserRequest(
            googleSub: userID,
            name: profile.name,
            email: profile.email,
            // GoogleのアイコンURLがない場合は空文字を送る
            iconURL: profile.imageURL(withDimension: 200)?.absoluteString ?? ""
        )

        guard let url = URL(string: backendURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        // 送信
        let (data, response) = try await URLSession.shared.data(for: request)

        // ステータスコード確認
        if let httpResponse = response as? HTTPURLResponse,
            !(200...299).contains(httpResponse.statusCode)
        {
            throw NSError(
                domain: "APIError", code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "サーバーエラー: \(httpResponse.statusCode)"])
        }

        // レスポンスからバックエンドのユーザーIDを取得して保存
        let decodedUser = try JSONDecoder().decode(BackendUserResponse.self, from: data)
        await MainActor.run {
            self.backendUserID = decodedUser.id
            print("🆔 Backend User ID obtained: \(decodedUser.id)")
        }
    }
}
