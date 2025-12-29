import SwiftUI

struct OptionsListView: View {
    @Binding var items: [Item]
    @Environment(\.dismiss) var dismiss
    @State private var newOptionText = ""

    var body: some View {
        ZStack {
            // Panel Background
            Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header Row
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.orbitGlass)
                }
                
                // Content Area
                VStack {
                    if items.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "square.stack.3d.up.slash")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.2))
                            Text("Your deck is empty.")
                                .font(Orbit.headingFont())
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(items) { item in
                                    itemRow(for: item)
                                }
                            }
                        }
                    }
                }
                
                // Input Bar at the bottom of the panel
                ControlBar(text: $newOptionText, onAdd: addOption, onShuffle: {})
            }
            .padding(16) // Consistent 16px padding all around
        }
        .preferredColorScheme(.dark)
    }

    // Helper for individual item rows
    func itemRow(for item: Item) -> some View {
        HStack(spacing: 16) {
            Circle().fill(item.color).frame(width: 14, height: 14)
            Text(item.text).font(Orbit.bodyFont()).foregroundStyle(.white)
            Spacer()
            Button(action: { withAnimation { items.removeAll { $0.id == item.id } } }) {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(.vertical, 12).padding(.horizontal, 20)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
    }

    func addOption() {
        guard !newOptionText.isEmpty else { return }
        if items.contains(where: { $0.text.localizedCaseInsensitiveCompare(newOptionText) == .orderedSame }) {
            newOptionText = ""; return
        }
        let newItem = Item(text: newOptionText, colorName: Theme.randomColorName())
        withAnimation(.spring()) { items.insert(newItem, at: 0) }
        newOptionText = ""
    }
}
