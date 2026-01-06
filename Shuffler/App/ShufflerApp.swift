import SwiftUI

@main
struct ShufflerApp: App {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasSeenOnboarding {
                    MainContainerView()
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
