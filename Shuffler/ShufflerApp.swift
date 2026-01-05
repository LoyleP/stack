import SwiftUI

@main
struct ShufflerApp: App {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                DeckView()
                    .transition(.opacity.combined(with: .scale))
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
    }
}
