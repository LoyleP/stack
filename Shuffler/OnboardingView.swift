import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var currentStep = 0
    
    // Updated steps using the helper struct defined below
    private let steps = [
        OnboardingStep(
            title: "Decision Made Easy",
            description: "Can't choose? Let Shuffler handle the pressure. Just add your options and let the deck decide.",
            icon: "square.stack.3d.up.fill",
            color: .cyan
        ),
        OnboardingStep(
            title: "Tactile Control",
            description: "Hold the Shuffle button for a continuous mix, or shake your phone to trigger a quick pick.",
            icon: "hand.tap.fill",
            color: .orange
        ),
        OnboardingStep(
            title: "Ready to Start?",
            description: "Your deck is waiting. Add your first set of options and get shuffling.",
            icon: "sparkles",
            color: .purple
        )
    ]

    var body: some View {
        ZStack {
            // Background color consistent with DeckView
            Color(red: 0.05, green: 0.06, blue: 0.07).ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentStep) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        stepView(for: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                VStack {
                    if currentStep == steps.count - 1 {
                        // "Let's get started" - Blue background, white text
                        Button(action: {
                            withAnimation(Orbit.morph) {
                                hasSeenOnboarding = true
                            }
                            Haptics.shared.play(.medium) // Tactile feedback
                        }) {
                            Text("Let's get started")
                                .font(Orbit.bodyFont())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48) // Fixed 48px height
                                .background(Capsule().fill(Theme.color(for: "denim"))) // Theme consistency
                        }
                    } else {
                        // "Next" - White background, black text
                        Button(action: {
                            withAnimation { currentStep += 1 }
                            Haptics.shared.play(.light) // Tactile feedback
                        }) {
                            Text("Next")
                                .font(Orbit.bodyFont())
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48) // Fixed 48px height
                                .background(Capsule().fill(.white))
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }

    private func stepView(for index: Int) -> some View {
        let step = steps[index]
        return VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(step.color.opacity(0.15))
                    .frame(width: 160, height: 160)
                
                Image(systemName: step.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(step.color)
            }
            .scaleEffect(currentStep == index ? 1 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentStep)

            VStack(spacing: 16) {
                Text(step.title)
                    .font(Orbit.headingFont()) // Design system typography
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .font(Orbit.bodyFont()) // Design system typography
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

// --- HELPER MODEL ---
// This must be outside the OnboardingView struct to be found correctly in scope
struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
    let color: Color
}
