import SwiftUI

struct CardView: View {
    let text: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Theme.gradient(for: color))
                .shadow(color: color.opacity(0.3), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(.white.opacity(0.3), lineWidth: 1.5)
                )
            
            Text(text)
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(30)
                .minimumScaleFactor(0.4) // Allows longer text to shrink
        }
        .frame(width: 310, height: 420) // Reduced height for keyboard safety
    }
}
