import SwiftUI

struct MainContainerView: View {
    @StateObject private var store = DeckStore()
    @State private var selectedTab = 0

    init() {
        // Customize standard TabView appearance to match Orbit
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.3)
        UITabBar.appearance().backgroundColor = UIColor(red: 0.05, green: 0.06, blue: 0.07, alpha: 1)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DeckView()
                .environmentObject(store)
                .tabItem {
                    Label("Shuffle", systemImage: "shuffle")
                }
                .tag(0)

            SavedDecksView(selectedTab: $selectedTab)
                .environmentObject(store)
                .tabItem {
                    Label("Saved", systemImage: "rectangle.stack.fill")
                }
                .tag(1)
        }
        .tint(Theme.color(for: "denim"))
    }
}
