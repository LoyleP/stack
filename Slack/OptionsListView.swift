import SwiftUI

struct OptionsListView: View {
    @Binding var items: [Item]
    @Environment(\.dismiss) var dismiss
    @State private var newOptionText = ""
    
    // NEW: Session state to ensure unique colors when adding multiple items in the list
    @State private var usedSessionColors: Set<String> = []
    
    // Tracks keyboard focus for the input bar
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            // Panel Background
            Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 1. Header Row
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.orbitGlass)
                }
                
                // 2. Content Area
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
                        .scrollDismissesKeyboard(.interactively)
                    }
                }
                
                // 3. Input Bar (Now passing focusState)
                ControlBar(
                    text: $newOptionText,
                    focusState: $isInputFocused,
                    onAdd: addOption,
                    onShuffle: {}
                )
            }
            .padding(16) // Consistent 16px padding all around the panel
        }
        .preferredColorScheme(.dark)
        .onAppear {
            usedSessionColors.removeAll() // Start fresh when opening the panel
        }
    }

    // --- HELPER VIEWS ---

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
            Button(action: {
                withAnimation {
                    items.removeAll { $0.id == item.id }
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 16) // Increased row height
        .padding(.horizontal, 20)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
    }

    // --- LOGIC ---

    func addOption() {
        guard !newOptionText.isEmpty else { return }
        
        // Prevent duplicate text
        if items.contains(where: { $0.text.localizedCaseInsensitiveCompare(newOptionText) == .orderedSame }) {
            newOptionText = ""
            return
        }
        
        // SESSION COLOR SELECTION: Unique colors until the pool is empty
        let available = Theme.colorNames.filter { !usedSessionColors.contains($0) }
        let finalPool = available.isEmpty ? Theme.colorNames : available
        let picked = finalPool.randomElement() ?? "denim"
        
        usedSessionColors.insert(picked)
        
        let newItem = Item(text: newOptionText, colorName: picked)
        withAnimation(.spring()) {
            items.insert(newItem, at: 0)
        }
        
        newOptionText = ""
        isInputFocused = true // Keep keyboard up for the next entry
    }
}
