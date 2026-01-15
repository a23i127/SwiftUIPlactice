// HomeView.swift

import SwiftUI

struct Memo: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var content: String
}

struct HomeView: View {
    @State private var memos: [Memo] = [
        Memo(title: "First Memo", content: "This is the content of the first memo."),
        Memo(title: "Second Memo", content: "This is the content of the second memo."),
        Memo(title: "Third Memo", content: "This is the content of the third memo."),
    ]
    @State private var showCreateMemoView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(memos) { memo in
                    NavigationLink(destination: MemoDetailView(memo: memo)) {
                        VStack(alignment: .leading) {
                            Text(memo.title)
                                .font(.headline)
                            Text(memo.content)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .onDelete(perform: deleteMemo)
            }
            .navigationTitle("メモ")
            .navigationBarItems(
                trailing:
                    Button(action: {
                        showCreateMemoView = true
                    }) {
                        Image(systemName: "plus")
                    }
            )
            .sheet(isPresented: $showCreateMemoView) {
                CreateMemoView(memos: $memos)
            }
        }
    }

    private func deleteMemo(at offsets: IndexSet) {
        memos.remove(atOffsets: offsets)
    }
}

struct MemoDetailView: View {
    let memo: Memo
    @EnvironmentObject var signInManager: GoogleSignInManager
    @State private var isPosting = false
    @State private var postError: String?
    @State private var shouldAutoPostAfterLogin = false

    var body: some View {
        VStack {
            Text(memo.title)
                .font(.largeTitle)
                .padding()
            Text(memo.content)
                .padding()

            if signInManager.currentUser != nil {
                Button(action: {
                    Task {
                        await postMemo()
                    }
                }) {
                    if isPosting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                    } else {
                        Text("投稿する")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .disabled(isPosting)
            } else {
                NavigationLink(destination: LoginView()) {
                    Text("投稿する")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    shouldAutoPostAfterLogin = true
                })
            }

            Spacer()
        }
        .navigationTitle(memo.title)
        .alert(
            "投稿エラー", isPresented: Binding(get: { postError != nil }, set: { _ in postError = nil })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(postError ?? "不明なエラー")
        }
        .onAppear {
            if shouldAutoPostAfterLogin, signInManager.currentUser != nil {
                Task {
                    await postMemo()
                }
                shouldAutoPostAfterLogin = false
            }
        }
    }

    private func postMemo() async {
        guard let authorID = signInManager.backendUserID else {
            postError = "ユーザー情報が取得できませんでした。再度ログインしてください。"
            return
        }

        isPosting = true
        postError = nil

        // 実機用にMacのIPアドレスを指定
        let url = URL(string: "http://192.168.100.50:8080/posts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "authorID": authorID.uuidString,
            "title": memo.title,
            "body": memo.content,
            "visibility": "public",
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

            print("✅ 投稿成功")
            // 必要であれば成功アラートを出すか画面を閉じる

        } catch {
            postError = error.localizedDescription
        }

        isPosting = false
    }
}

struct CreateMemoView: View {
    @Binding var memos: [Memo]
    @State private var title: String = ""
    @State private var content: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                }
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(height: 200)
                }
            }
            .navigationTitle("New Memo")
            .navigationBarItems(
                leading:
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                trailing:
                    Button("Save") {
                        let newMemo = Memo(title: title, content: content)
                        memos.append(newMemo)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
            )
        }
    }
}

#Preview {
    HomeView()
}
