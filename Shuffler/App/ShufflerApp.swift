import SwiftUI

@main
struct ShufflerApp: App {
    // Declaring the store here resolves scope errors in DeckView
    @StateObject private var store = DeckStore()
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        // Sets the navbar background to a dark, semi-transparent color
        appearance.backgroundColor = UIColor(
            red: 0.05,
            green: 0.06,
            blue: 0.07,
            alpha: 0.85
        )

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasSeenOnboarding {
                    DeckView()
                        .environmentObject(store)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.95).combined(
                                    with: .opacity
                                ),
                                removal: .opacity
                            )
                        )
                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            }
            .animation(Orbit.Dynamics.background, value: hasSeenOnboarding)
        }
    }
}
