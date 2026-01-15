import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var signInManager: GoogleSignInManager
    @Environment(\.dismiss) private var dismiss
    @State private var showDebugView = false

    var body: some View {
        VStack {
            if let user = signInManager.currentUser {
                VStack {
                    Text("ログイン成功！")
                        .font(.largeTitle)
                    Text("ようこそ, \(user.profile?.name ?? "") さん")
                    
                    Button("元の画面に戻る") {
                        dismiss()
                    }
                    .padding()
                    
                    Button("サインアウト", action: signInManager.signOut)
                }
            } else {
                Text("ログインが必要です")
                    .font(.largeTitle)
                    .padding()

                GoogleSignInButton {
                    Task {
                        await signInManager.signIn()
                        if signInManager.currentUser != nil {
                            dismiss()
                        }
                    }
                }
                .padding()
            }

            if let errorMessage = signInManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("デバッグ情報を表示") {
                showDebugView = true
            }
            .padding(.top, 20)
            .foregroundColor(.secondary)
            .sheet(isPresented: $showDebugView) {
                GoogleSignInDebugView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(GoogleSignInManager())
    }
}
