import SwiftUI

struct CardView: View {
    let text: String
    let color: Color
    
    var body: some View {
        ZStack {
            // 1. The Card Body
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Theme.gradient(for: color))
                // The Shadow makes it pop off the screen
                .shadow(color: color.opacity(0.3), radius: 20, x: 0, y: 10)
                // A thin white border adds a "premium finish"
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(.white.opacity(0.3), lineWidth: 1.5)
                )
            
            // 2. The Text
            Text(text)
                .font(.system(size: 40, weight: .black, design: .rounded)) // <-- Rounded Font
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(30)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1) // Text drop shadow
                .minimumScaleFactor(0.5)
        }
        .frame(width: 320, height: 460) // Slightly larger, more cinematic
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CardView(text: "Designer\nApps", color: .indigo)
    }
}
