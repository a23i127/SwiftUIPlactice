// PageView.swift

import SwiftUI

struct PageView: View {
    let title: String

    var body: some View {
        PostListView(title: title)
    }
}

// 投稿一覧を表示するView
struct PostListView: View {
    let title: String
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    // 実機テスト用のIPアドレス
    private let apiURL = "http://192.168.100.50:8080/posts"

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("読み込み中...")
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("再試行") {
                            Task { await fetchPosts() }
                        }
                    }
                } else if posts.isEmpty {
                    Text("投稿がありません")
                        .foregroundColor(.secondary)
                } else {
                    List(posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            HStack(alignment: .top, spacing: 12) {
                                // アイコン
                                if let url = URL(string: post.author.iconURL) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .overlay(
                                                Text(post.author.name.prefix(1)).font(.caption))
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .overlay(Text(post.author.name.prefix(1)).font(.caption))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        // 名前
                                        Text(post.author.name)
                                            .font(.headline)

                                        Spacer()

                                        if let date = post.createdAt {
                                            Text(date.formatted(.dateTime.locale(Locale(identifier: "ja_JP")).month().day().hour().minute()))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    // タイトル
                                    Text(post.title)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        // プルリフレッシュ時は全画面ローディングを出さない
                        await fetchPosts(isRefresh: true)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await fetchPosts() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                // 初回はローディングを出すが、既にデータがあれば出さない等の制御も可能
                await fetchPosts()
            }
        }
    }

    private func fetchPosts(isRefresh: Bool = false) async {
        print("🚀 fetchPosts started")
        
        // プルリフレッシュの場合は isLoading を true にしない
        // (Listが消えてしまい、refreshable処理が中断されるのを防ぐため)
        if !isRefresh {
            isLoading = true
        }
        
        errorMessage = nil

        guard let url = URL(string: apiURL) else {
            print("❌ Invalid URL")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                print("❌ Server Error: \(httpResponse.statusCode)")
                throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "サーバーエラー: \(httpResponse.statusCode)"])
            }

            // Vaporのデフォルトの日付フォーマット(ISO8601)に対応するデコーダー
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let decodedPosts = try decoder.decode([Post].self, from: data)
            print("✅ fetchPosts success: \(decodedPosts.count) posts found")

            self.posts = decodedPosts

        } catch {
            print("❌ Error fetching posts: \(error)")
            self.errorMessage = "データの取得に失敗しました。\n\(error.localizedDescription)"
        }

        isLoading = false
    }
}
