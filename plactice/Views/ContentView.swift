// filepath: /Users/sakusann/plactice/plactice/ContentView.swift
//
//  ContentView.swift
//  plactice
//
//  Created by 高橋沙久哉 on 2025/12/05.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Int = 0

    private let tabs: [TabItem] = [
        TabItem(title: "Home", systemImage: "house.fill"),
        TabItem(title: "Search", systemImage: "magnifyingglass"),
        TabItem(title: "Profile", systemImage: "person.circle"),
        TabItem(title: "Test", systemImage: "testtube.2")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selection) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Group {
                        if tab.title == "Profile" {
                            ProfileView()
                        } else if tab.title == "Test" {
                            TestView()
                        } else {
                            PageView(title: tab.title)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: selection)

            Divider()

            CustomTabBar(selection: $selection, tabs: tabs)
                .frame(height: 60)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
