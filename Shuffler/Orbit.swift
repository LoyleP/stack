import SwiftUI

struct Orbit {
    static func headingFont() -> Font { .system(size: 22, weight: .heavy, design: .rounded) }
    static func bodyFont() -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    
    static let glassMaterial: Material = .ultraThinMaterial
    static let glassBorder: Color = .white.opacity(0.3)
    static let glassBorderWidth: CGFloat = 1.0
    
    static let touch = Animation.spring(response: 0.2, dampingFraction: 0.6)
    static let morph = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let gravity = Animation.spring(response: 0.6, dampingFraction: 0.8)
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
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(Orbit.touch, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == OrbitGlassButtonStyle {
    static var orbitGlass: OrbitGlassButtonStyle { OrbitGlassButtonStyle() }
}
