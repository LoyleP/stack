import SwiftUI

struct ControlBar: View {
    @Binding var text: String
    var focusState: FocusState<Bool>.Binding // The parameter that was missing
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
                .overlay(
                    Capsule().stroke(Orbit.glassBorder, lineWidth: Orbit.glassBorderWidth)
                )
                .foregroundStyle(.white)
                .tint(.white)
                .submitLabel(.done)
                .focused(focusState) // NEW: Link to the focus state
                .onSubmit { onAdd() }
            
            Button(action: onAdd) {
                Image(systemName: "arrow.up")
            }
            .buttonStyle(.orbitGlass)
            .disabled(text.isEmpty)
            .opacity(text.isEmpty ? 0.5 : 1)
        }
        // Removed .padding(.horizontal, 20) to maintain consistent 16px alignment
    }
}
