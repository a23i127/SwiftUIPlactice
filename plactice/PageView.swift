// PageView.swift

import SwiftUI

struct PageView: View {
    let title: String
    var body: some View {
        if title == "Home" {
            HomeView()
        } else {
            DefaultPageView(title: title)
        }
    }
}

struct DefaultPageView: View {
    let title: String
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 60))
                Text(title)
                    .font(.largeTitle)
                    .bold()
                Text("左右にスワイプしてタブを切り替えられます")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
        }
    }
}
