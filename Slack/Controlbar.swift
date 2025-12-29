import SwiftUI

struct ControlBar: View {
    @Binding var text: String
    var onAdd: () -> Void
    var onShuffle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("", text: $text, prompt: Text("Add an option...").foregroundColor(.white.opacity(0.5)))
                .font(Orbit.bodyFont())
                .padding(.horizontal, 20)
                .frame(height: 56)
                .background(Orbit.glassMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Orbit.glassBorder, lineWidth: Orbit.glassBorderWidth))
                .foregroundStyle(.white)
                .tint(.white)
                .submitLabel(.done)
                .onSubmit { onAdd() }
            
            Button(action: onAdd) { Image(systemName: "arrow.up") }
                .buttonStyle(.orbitGlass)
                .disabled(text.isEmpty)
                .opacity(text.isEmpty ? 0.5 : 1)
        }
    }
}
