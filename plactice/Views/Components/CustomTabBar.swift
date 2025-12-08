// CustomTabBar.swift

import SwiftUI

struct CustomTabBar: View {
    @Binding var selection: Int
    let tabs: [TabItem]

    var body: some View {
        HStack {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button(action: {
                    withAnimation {
                        selection = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(selection == index ? Color.accentColor : Color.gray)
                        Text(tab.title)
                            .font(.caption)
                            .foregroundColor(selection == index ? Color.accentColor : Color.gray)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
        .background(VisualEffectBlur().edgesIgnoringSafeArea(.bottom))
    }
}

#if DEBUG
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selection: .constant(0), tabs: [
            TabItem(title: "Home", systemImage: "house.fill"),
            TabItem(title: "Search", systemImage: "magnifyingglass"),
            TabItem(title: "Profile", systemImage: "person.circle")
        ])
        .previewLayout(.sizeThatFits)
    }
}
#endif
