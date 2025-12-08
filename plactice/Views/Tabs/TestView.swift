// TestView.swift

import SwiftUI

// @Bindingでデータを受け取る子ビュー
struct ChildView: View {
    @Binding var text: String

    var body: some View {
        VStack {
            Text("子ビュー")
                .font(.headline)
            TextField("ここに入力", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// @Stateでデータを所有する親ビュー
struct TestView: View {
    @State private var message: String = "こんにちは！"

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("親ビュー")
                    .font(.largeTitle)
                    .bold()
                
                Text("現在のメッセージ: \(message)")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                // @Stateの値を@Bindingで子ビューに渡す
                ChildView(text: $message)
                
                Text("子ビューのテキストフィールドに入力すると、親ビューのメッセージがリアルタイムで更新されます。")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("State & Binding")
            .navigationBarHidden(true)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
