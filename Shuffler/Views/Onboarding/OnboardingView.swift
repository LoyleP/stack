import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var currentStep = 0
    private let steps = [
        OnboardingStep(title: "Decision Made Easy", description: "Can't choose? Let Shuffler handle the pressure. Just add your options and let the deck decide.", icon: "square.stack.3d.up.fill", color: .cyan),
        OnboardingStep(title: "Tactile Control", description: "Hold the Shuffle button for a continuous mix, or shake your phone to trigger a quick pick.", icon: "hand.tap.fill", color: .orange),
        OnboardingStep(title: "Ready to Start?", description: "Your deck is waiting. Add your first set of options and get shuffling.", icon: "sparkles", color: .purple)
    ]

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.06, blue: 0.07).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 6) { ForEach(0..<steps.count, id: \.self) { Capsule().fill($0 <= currentStep ? .white : .white.opacity(0.2)).frame(height: 4) } }
                .padding(.horizontal, 20).padding(.top, 8).animation(Orbit.Dynamics.panel, value: currentStep)
                
                GeometryReader { geo in
                    ZStack {
                        TabView(selection: $currentStep) { ForEach(0..<steps.count, id: \.self) { stepView(for: $0).tag($0) } }.tabViewStyle(.page(indexDisplayMode: .never))
                        HStack(spacing: 0) {
                            Color.clear.contentShape(Rectangle()).onTapGesture { if currentStep > 0 { withAnimation(Orbit.Dynamics.panel) { currentStep -= 1 }; Haptics.shared.play(.light) } }.frame(width: geo.size.width * 0.35)
                            Color.clear.contentShape(Rectangle()).onTapGesture { if currentStep < steps.count - 1 { withAnimation(Orbit.Dynamics.panel) { currentStep += 1 }; Haptics.shared.play(.light) } }.frame(maxWidth: .infinity)
                        }
                    }
                }
                
                VStack {
                    if currentStep == steps.count - 1 {
                        Button(action: { withAnimation(Orbit.Dynamics.background) { hasSeenOnboarding = true }; Haptics.shared.play(.medium) }) {
                            HStack(spacing: 8) { Text("Let's get started"); Image(systemName: "sparkles") }.font(Orbit.bodyFont()).foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 50).background(Capsule().fill(Theme.color(for: "denim")))
                        }
                    } else {
                        Button(action: { withAnimation(Orbit.Dynamics.panel) { currentStep += 1 }; Haptics.shared.play(.light) }) {
                            HStack(spacing: 8) { Text("Next"); Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)) }.font(Orbit.bodyFont()).foregroundStyle(.black).frame(maxWidth: .infinity).frame(height: 50).background(Capsule().fill(.white))
                        }
                    }
                }.padding(.horizontal, 20).padding(.bottom, 20)
            }
        }
    }

    private func stepView(for index: Int) -> some View {
        let step = steps[index]
        return VStack(spacing: 30) {
            ZStack { Circle().fill(step.color.opacity(0.15)).frame(width: 160, height: 160); Image(systemName: step.icon).font(.system(size: 60)).foregroundStyle(step.color) }
            .scaleEffect(currentStep == index ? 1 : 0.8).animation(Orbit.Dynamics.physics, value: currentStep)
            VStack(spacing: 16) { Text(step.title).font(Orbit.headingFont()).foregroundStyle(.white).multilineTextAlignment(.center); Text(step.description).font(Orbit.bodyFont()).foregroundStyle(.white.opacity(0.6)).multilineTextAlignment(.center).padding(.horizontal, 20) }
        }
    }
}

struct OnboardingStep { let title, description, icon: String; let color: Color }
