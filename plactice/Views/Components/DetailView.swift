import SwiftUI

// 詳細画面
struct PostDetailView: View {
    let post: Post
    @State private var showCommentInput = false
    @State private var comments: [Comment] = []
    @State private var isLoadingComments = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ヘッダー: 投稿者情報
                HStack(spacing: 12) {
                    if let url = URL(string: post.author.iconURL) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(Text(post.author.name.prefix(1)).font(.headline))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.author.name)
                            .font(.headline)

                        if let date = post.createdAt {
                            Text(
                                date.formatted(
                                    .dateTime.locale(Locale(identifier: "ja_JP")).year().month()
                                        .day().hour().minute())
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                }

                Divider()

                // タイトル
                Text(post.title)
                    .font(.title2)
                    .bold()

                // 本文
                Text(post.body)
                    .font(.body)
                    .lineSpacing(6)

                // コメント投稿ボタン
                Button {
                    showCommentInput = true
                } label: {
                    HStack {
                        Image(systemName: "bubble.left.fill")
                        Text("コメントを投稿する")
                    }
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)

                Divider()

                // コメント一覧セクション
                VStack(alignment: .leading, spacing: 15) {
                    Text("コメント")
                        .font(.headline)
                        .padding(.bottom, 5)

                    if isLoadingComments {
                        ProgressView()
                            .padding()
                    } else if comments.isEmpty {
                        Text("まだコメントはありません")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(comments) { comment in
                            HStack(alignment: .top, spacing: 12) {
                                // アイコン
                                if let url = URL(string: comment.user.iconURL) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 36, height: 36)
                                        .overlay(Text(comment.user.name.prefix(1)).font(.caption))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(comment.user.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        if let date = comment.createdAt {
                                            Text(
                                                date.formatted(
                                                    .dateTime.locale(Locale(identifier: "ja_JP"))
                                                        .month().day().hour().minute())
                                            )
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        }
                                    }
                                    Text(comment.body)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("投稿詳細")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(
            isPresented: $showCommentInput,
            onDismiss: {
                // 投稿画面から戻ってきた時にコメントを再取得して即反映
                Task { await fetchComments() }
            }
        ) {
            CommentInputView(postID: post.id)
        }
        .onAppear {
            // 詳細画面が開かれた時にコメントを取得
            Task {
                await fetchComments()
            }
        }
    }

    private func fetchComments() async {
        isLoadingComments = true
        // 実機テスト用のIPアドレス
        let apiURL = "http://192.168.100.50:8080/comments/post/\(post.id)"

        guard let url = URL(string: apiURL) else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse,
                !(200...299).contains(httpResponse.statusCode)
            {
                print("Error fetching comments: \(httpResponse.statusCode)")
                isLoadingComments = false
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let decodedComments = try decoder.decode([Comment].self, from: data)
            self.comments = decodedComments

        } catch {
            print("Error fetching comments: \(error)")
        }
        isLoadingComments = false
    }
}
