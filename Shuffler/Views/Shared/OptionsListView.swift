import SwiftUI

struct OptionsListView: View {
    @Binding var items: [Item]
    @Binding var isPresented: Bool
    @State private var newOptionText = ""
    @State private var usedSessionColors: Set<String> = []
    @FocusState private var isInputFocused: Bool
    @State private var showClearConfirmation = false
    
    var body: some View {
        ZStack {
            // Full screen background
            Color(red: 0.05, green: 0.06, blue: 0.07).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Symmetrical Header (Left Align Title, Right Align Back Button)
                HStack {
                    Text("Deck Options").font(Orbit.headingFont()).foregroundStyle(.white)
                    Spacer()
                    Button(action: { withAnimation(Orbit.Dynamics.panel) { isPresented = false } }) {
                        Image(systemName: "chevron.right").font(.system(size: 16, weight: .bold))
                    }.buttonStyle(.orbitGlass)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 20)
                
                // Content
                VStack {
                    if items.isEmpty {
                        emptyState
                    } else {
                        List {
                            Section {
                                ForEach(items) { item in
                                    itemRow(for: item)
                                }
                                .onDelete { indexSet in
                                    items.remove(atOffsets: indexSet)
                                    Haptics.shared.selectionRemoved()
                                }
                            } header: {
                                if !items.isEmpty {
                                    Button("Clear All") { showClearConfirmation = true }
                                        .font(.caption).foregroundStyle(.red)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
                
                // Floating Input Bar
                ControlBar(text: $newOptionText, focusState: $isInputFocused, onAdd: addOption, onShuffle: {})
                    .padding(20)
            }
            .blur(radius: showClearConfirmation ? 10 : 0)
            
            if showClearConfirmation {
                clearAlertOverlay
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Components
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "square.stack.3d.up.slash").font(.system(size: 50)).foregroundStyle(.white.opacity(0.2))
            Text("No options yet").font(Orbit.bodyFont()).foregroundStyle(.white.opacity(0.4))
            Spacer()
        }
    }

    private func itemRow(for item: Item) -> some View {
        HStack {
            Circle().fill(item.color).frame(width: 12, height: 12)
            Text(item.text).font(Orbit.bodyFont()).foregroundStyle(.white)
        }
        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
    }

    private var clearAlertOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { showClearConfirmation = false }
            VStack(spacing: 24) {
                Text("Clear everything?").font(Orbit.headingFont())
                HStack(spacing: 16) {
                    Button("Cancel") { showClearConfirmation = false }.buttonStyle(.plain)
                    Button("Clear All") { items.removeAll(); showClearConfirmation = false }.foregroundStyle(.red)
                }
            }
            .padding(24).background(Orbit.glassMaterial).clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    func addOption() {
        guard !newOptionText.isEmpty else { return }
        let picked = Theme.randomColorName()
        withAnimation(Orbit.Dynamics.element) { items.insert(Item(text: newOptionText, colorName: picked), at: 0) }
        newOptionText = ""
    }
}
