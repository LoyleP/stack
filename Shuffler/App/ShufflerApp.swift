import SwiftUI

@main
struct ShufflerApp: App {
    // Declaring the store here resolves scope errors in DeckView
    @StateObject private var store = DeckStore()
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasSeenOnboarding {
                    DeckView()
                        .environmentObject(store)
                        .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))
                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            }
            .animation(Orbit.Dynamics.background, value: hasSeenOnboarding)
        }
    }
}
