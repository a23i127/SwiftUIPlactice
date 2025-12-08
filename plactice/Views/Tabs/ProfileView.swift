// ProfileView.swift

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Avatar
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(.secondary)
                    .padding(.top, 24)

                // Name and handle
                VStack(spacing: 4) {
                    Text("高橋 沙久哉")
                        .font(.title2)
                        .bold()
                    Text("@sakuya")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Bio
                Text("iOS開発が好きなエンジニア。Swift / SwiftUI を触っています。サンプルプロジェクトのデモプロファイルです。")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Stats
                HStack(spacing: 24) {
                    VStack {
                        Text("120")
                            .font(.headline)
                        Text("フォロー")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text("340")
                            .font(.headline)
                        Text("フォロワー")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text("45")
                            .font(.headline)
                        Text("投稿")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)

                // Action buttons
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("プロフィールを編集")
                            .font(.subheadline).bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor, lineWidth: 1))
                    }

                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .frame(width: 44, height: 44)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                }
                .padding(.horizontal)

                // Simple list of items
                VStack(spacing: 0) {
                    ForEach(["投稿", "いいね", "設定", "ログアウト"], id: \ .self) { label in
                        HStack {
                            Text(label)
                                .padding(.vertical, 14)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding()

                Spacer()
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("プロフィール")
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
#endif
