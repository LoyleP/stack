import SwiftUI

struct ControlBar: View {
    @Binding var text: String
    var onAdd: () -> Void
    var onShuffle: () -> Void // We keep this signature, even if unused in some contexts
    
    var body: some View {
        HStack(spacing: 12) {
            // 1. The Input Field (Capsule)
            TextField("", text: $text, prompt: Text("Add an option...").foregroundColor(.white.opacity(0.5)))
                .font(Orbit.bodyFont()) // <--- Uses Orbit Font
                .padding(.horizontal, 20)
                .frame(height: 56) // <--- Standard height
                .background(Orbit.glassMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Orbit.glassBorder, lineWidth: Orbit.glassBorderWidth)
                )
                .foregroundStyle(.white)
                .tint(.white)
                .submitLabel(.done)
                .onSubmit { onAdd() }
            
            // 2. The Add Button (Integrated)
            // We use the Orbit Glass style, but slightly modified to remove the background
            // since it sits next to the bar, or we keep it consistent.
            // Let's keep it consistent: A circle button next to the capsule.
            Button(action: onAdd) {
                Image(systemName: "arrow.up") // Simple arrow
            }
            .buttonStyle(.orbitGlass) // <--- ONE LINE TO STYLE IT
            .disabled(text.isEmpty)
            .opacity(text.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 20)
    }
}
