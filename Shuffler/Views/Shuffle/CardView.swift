import SwiftUI

struct CardView: View {
    let text: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Theme.gradient(for: color))
                .shadow(color: color.opacity(0.3), radius: 25, x: 0, y: 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1.5)
                )
            
            Text(text)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(30)
                .minimumScaleFactor(0.4)
        }
        .frame(width: 320, height: 460)
    }
}
