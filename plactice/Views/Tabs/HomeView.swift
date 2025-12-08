// HomeView.swift

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Welcome Home!")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)

                    // Featured Section
                    VStack(alignment: .leading) {
                        Text("Featured")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<5) { _ in
                                    FeaturedCard()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Recent Activity Section
                    VStack(alignment: .leading) {
                        Text("Recent Activity")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach(0..<3) { index in
                                ActivityRow(index: index)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Home")
            .navigationBarHidden(true)
        }
    }
}

struct FeaturedCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 120)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
            Text("Interesting Place")
                .font(.headline)
            Text("Short description")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(width: 200)
    }
}

struct ActivityRow: View {
    let index: Int
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text("Activity \(index + 1)")
                    .font(.headline)
                Text("This is a description of the recent activity.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("2h ago")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
