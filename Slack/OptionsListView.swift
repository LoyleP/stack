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
                            LazyVStack(spacing: 16) { // Comfortably spaced
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
            .padding(16) // 16px all-around padding preserved
        }
        .preferredColorScheme(.dark)
    }

    // UPDATED: Cleaned itemRow (No Context Menu)
    func itemRow(for item: Item) -> some View {
        HStack(spacing: 16) {
            // Larger color circle (22px)
            Circle()
                .fill(item.color)
                .frame(width: 22, height: 22)
                .shadow(color: item.color.opacity(0.6), radius: 4)

            Text(item.text)
                .font(Orbit.bodyFont())
                .foregroundStyle(.white)
            
            Spacer()
            
            // Larger cross button (22px)
            Button(action: { withAnimation { items.removeAll { $0.id == item.id } } }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 16) // Increased row height preserved
        .padding(.horizontal, 20)
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
