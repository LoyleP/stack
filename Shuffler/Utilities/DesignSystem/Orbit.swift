// Orbit.swift

import SwiftUI

struct Orbit {
    static func headingFont() -> Font { .system(size: 22, weight: .heavy, design: .rounded) }
    static func bodyFont() -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    
    static let glassMaterial: Material = .ultraThinMaterial
    static let glassBorder: Color = .white.opacity(0.3)
    static let glassBorderWidth: CGFloat = 1.0
    
    // --- THE SEMANTIC DYNAMICS SYSTEM ---
    struct Dynamics {
        /// For tracking gestures in real-time
        static let gesture = Animation.spring(response: 0.15, dampingFraction: 0.8)
        /// For small UI elements and buttons
        static let element = Animation.spring(response: 0.3, dampingFraction: 0.7)
        /// For card movements and physics objects
        static let physics = Animation.spring(response: 0.42, dampingFraction: 0.62)
        /// For sliding drawers and floating panels
        /// TUNE 'response' HERE to change drawer transition speed
        static let panel = Animation.spring(response: 0.55, dampingFraction: 0.88)
        /// For background gradients and major state transitions
        static let background = Animation.spring(response: 0.7, dampingFraction: 0.9)
    }
}

struct OrbitGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)
            .background(Orbit.glassMaterial)
            .clipShape(Circle())
            .overlay(Circle().stroke(Orbit.glassBorder, lineWidth: Orbit.glassBorderWidth))
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(Orbit.Dynamics.gesture, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == OrbitGlassButtonStyle {
    static var orbitGlass: OrbitGlassButtonStyle { OrbitGlassButtonStyle() }
}
