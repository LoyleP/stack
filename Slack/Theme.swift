import SwiftUI

struct Theme {
    // 1. The Palette (String Keys)
    static let colorNames: [String] = [
        "indigo", "purple", "pink", "orange", "teal", "blue", "mint", "red"
    ]
    
    // 2. Helper: String -> Color
    static func color(for name: String) -> Color {
        switch name {
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        case "orange": return .orange
        case "teal": return .teal
        case "blue": return .blue
        case "mint": return .mint
        case "red": return .red
        default: return .blue // Fallback
        }
    }
    
    // 3. Helper: Get a random color name
    static func randomColorName() -> String {
        return colorNames.randomElement() ?? "blue"
    }
    
    // 4. The Gradient Builder
    static func gradient(for color: Color) -> LinearGradient {
        return LinearGradient(
            colors: [color, color], // Solid, no opacity
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
