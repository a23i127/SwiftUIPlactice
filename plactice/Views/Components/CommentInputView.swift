import SwiftUI

struct CommentInputView: View {
    let postID: UUID
    @EnvironmentObject var signInManager: GoogleSignInManager
    @Environment(\.presentationMode) var presentationMode

    @State private var commentBody: String = ""
    @State private var isPosting = false
    @State private var postError: String?
    @State private var shouldAutoPostAfterLogin = false

    var body: some View {
        NavigationView {
            VStack {
                Text("コメントを入力してください")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: $commentBody)
                    .frame(height: 200)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding()

                if let error = postError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                if signInManager.currentUser != nil {
                    Button(action: {
                        Task {
                            await postComment()
                        }
                    }) {
                        if isPosting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .cornerRadius(8)
                        } else {
                            Text("投稿する")
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(
                                    commentBody.trimmingCharacters(in: .whitespacesAndNewlines)
                                        .isEmpty ? Color.gray : Color.blue
                                )
                                .cornerRadius(8)
                        }
                    }
                    .disabled(
                        isPosting
                            || commentBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                    .padding()
                } else {
                    VStack {
                        Text("コメントを投稿するにはログインが必要です")
                            .foregroundColor(.secondary)
                            .padding()
                        
                        NavigationLink(destination: LoginView()) {
                            Text("ログイン画面へ")
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding()
                        .simultaneousGesture(TapGesture().onEnded {
                            shouldAutoPostAfterLogin = true
                        })
                    }
                }

                Spacer()
            }
            .navigationTitle("コメント投稿")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
        .onAppear {
            if shouldAutoPostAfterLogin, signInManager.currentUser != nil, !commentBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Task {
                    await postComment()
                }
                shouldAutoPostAfterLogin = false
            }
        }
    }

    private func postComment() async {
        guard let userID = signInManager.backendUserID else {
            postError = "ユーザー情報が取得できませんでした。再度ログインしてください。"
            return
        }

        isPosting = true
        postError = nil

        // APIエンドポイント: POST /comments/:userID
        let urlString = "http://192.168.100.50:8080/comments/\(userID.uuidString)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "postID": postID.uuidString,
            "body": commentBody,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
                !(200...299).contains(httpResponse.statusCode)
            {
                throw NSError(
                    domain: "APIError", code: httpResponse.statusCode,
                    userInfo: [
                        NSLocalizedDescriptionKey: "投稿に失敗しました (Status: \(httpResponse.statusCode))"
                    ])
            }

            print("✅ コメント投稿成功")
            presentationMode.wrappedValue.dismiss()

        } catch {
            postError = error.localizedDescription
        }

        isPosting = false
    }
}
