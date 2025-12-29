import SwiftUI

struct Orbit {
    // --- 1. FONTS ---
    static func titleFont() -> Font { .system(size: 40, weight: .black, design: .rounded) }
    static func headingFont() -> Font { .system(size: 22, weight: .heavy, design: .rounded) }
    static func bodyFont() -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    
    // --- 2. MATERIALS ---
    static let glassMaterial: Material = .ultraThinMaterial
    static let glassBorder: Color = .white.opacity(0.3)
    static let glassBorderWidth: CGFloat = 1.0
    static let iconSize: CGFloat = 22
    static let iconWeight: Font.Weight = .bold
    
    // --- 3. THE PHYSICS ENGINE (New) ---
    // A. Touch (Buttons): Instant feedback, high tension.
    static let touch = Animation.spring(response: 0.2, dampingFraction: 0.6)
    
    // B. Morph (Layouts): Fast resizing, changing shapes.
    static let morph = Animation.spring(response: 0.4, dampingFraction: 0.75)
    
    // C. Gravity (Cards): Heavy, slow-settling inertia.
    static let gravity = Animation.spring(response: 0.6, dampingFraction: 0.8)
}

// --- 4. REUSABLE COMPONENTS ---

struct OrbitGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Orbit.iconSize, weight: Orbit.iconWeight))
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)
            .background(Orbit.glassMaterial)
            .clipShape(Circle())
            .overlay(Circle().stroke(Orbit.glassBorder, lineWidth: Orbit.glassBorderWidth))
            // Apply Orbit Physics
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(Orbit.touch, value: configuration.isPressed)
    }
}

struct OrbitPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Orbit.headingFont())
            .foregroundStyle(.black)
            .padding(.horizontal, 30)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(Capsule())
            // Apply Orbit Physics
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(Orbit.touch, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == OrbitGlassButtonStyle {
    static var orbitGlass: OrbitGlassButtonStyle { OrbitGlassButtonStyle() }
}

extension ButtonStyle where Self == OrbitPrimaryButtonStyle {
    static var orbitPrimary: OrbitPrimaryButtonStyle { OrbitPrimaryButtonStyle() }
}
