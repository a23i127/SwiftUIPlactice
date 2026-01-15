import GoogleSignIn
import SwiftUI

struct GoogleSignInDebugView: View {
    @State private var debugInfo: [String] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            List {
                Section("Google Sign-In 設定状況") {
                    ForEach(debugInfo, id: \.self) { info in
                        Text(info)
                            .font(.system(.caption, design: .monospaced))
                    }
                }

                Section("アクション") {
                    Button("設定を再読み込み") {
                        loadDebugInfo()
                    }

                    Button("設定をリセット") {
                        resetGoogleSignIn()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("デバッグ情報")
            .onAppear {
                loadDebugInfo()
            }
        }
        .overlay {
            if isLoading {
                ProgressView("読み込み中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }
        }
    }

    private func loadDebugInfo() {
        isLoading = true
        debugInfo.removeAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Google Sign-In設定確認
            if let config = GIDSignIn.sharedInstance.configuration {
                debugInfo.append("✅ GIDConfiguration設定済み")
                debugInfo.append("   Client ID: \(config.clientID)")
                if let serverClientID = config.serverClientID {
                    debugInfo.append("   Server Client ID: \(serverClientID)")
                } else {
                    debugInfo.append("   Server Client ID: 未設定")
                }
            } else {
                debugInfo.append("❌ GIDConfiguration未設定")
            }

            // 現在のユーザー状態確認
            if let currentUser = GIDSignIn.sharedInstance.currentUser {
                debugInfo.append("✅ ユーザーサインイン済み")
                debugInfo.append("   ユーザーID: \(currentUser.userID ?? "不明")")
                debugInfo.append("   名前: \(currentUser.profile?.name ?? "不明")")
                debugInfo.append("   Given Name: \(currentUser.profile?.givenName ?? "不明")")
                debugInfo.append("   Family Name: \(currentUser.profile?.familyName ?? "不明")")
                debugInfo.append("   メール: \(currentUser.profile?.email ?? "不明")")
                
                if let profile = currentUser.profile, profile.hasImage {
                    debugInfo.append("   画像: あり")
                    if let url = profile.imageURL(withDimension: 120) {
                        debugInfo.append("   画像URL: \(url.absoluteString)")
                    }
                } else {
                    debugInfo.append("   画像: なし")
                }
                
                if let idToken = currentUser.idToken {
                    debugInfo.append("   ID Token: \(String(idToken.tokenString.prefix(20)))...")
                }
            } else {
                debugInfo.append("❌ ユーザー未サインイン")
            }

            // Bundle情報確認
            debugInfo.append("📱 Bundle ID: \(Bundle.main.bundleIdentifier ?? "不明")")

            // URLスキーム確認
            if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] {
                debugInfo.append("✅ URL Schemes設定済み:")
                for urlType in urlTypes {
                    if let schemes = urlType["CFBundleURLSchemes"] as? [String] {
                        for scheme in schemes {
                            debugInfo.append("   - \(scheme)")
                        }
                    }
                }
            } else {
                debugInfo.append("❌ URL Schemes未設定")
            }

            // ウィンドウ情報確認
            let windowScenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
            debugInfo.append("🪟 Window Scenes: \(windowScenes.count)")

            for (index, scene) in windowScenes.enumerated() {
                debugInfo.append("   Scene \(index + 1): \(scene.session.role)")
                let keyWindows = scene.windows.filter { $0.isKeyWindow }
                debugInfo.append("   Key Windows: \(keyWindows.count)")

                if let keyWindow = keyWindows.first,
                    let rootVC = keyWindow.rootViewController
                {
                    debugInfo.append("   Root VC: \(type(of: rootVC))")
                }
            }

            isLoading = false
        }
    }

    private func resetGoogleSignIn() {
        GIDSignIn.sharedInstance.signOut()
        debugInfo.append("🔄 Google Sign-In をリセットしました")
    }
}

struct GoogleSignInDebugView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSignInDebugView()
    }
}
