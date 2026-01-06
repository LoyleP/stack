import SwiftUI

struct OptionsListView: View {
    @Binding var items: [Item]
    @Binding var isPresented: Bool
    @State private var newOptionText = ""
    @State private var usedSessionColors: Set<String> = []
    @FocusState private var isInputFocused: Bool
    @State private var showClearConfirmation = false
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    if !items.isEmpty {
                        Button(action: { withAnimation(Orbit.Dynamics.panel) { showClearConfirmation = true }; Haptics.shared.play(.light) }) {
                            Text("Clear All").font(Orbit.bodyFont()).foregroundStyle(.red.opacity(0.8))
                        }
                    }
                    Spacer()
                    Button(action: { withAnimation(Orbit.Dynamics.panel) { isPresented = false } }) { Image(systemName: "checkmark") }.buttonStyle(.orbitGlass)
                }
                VStack {
                    if items.isEmpty {
                        Spacer(); VStack(spacing: 32) {
                            VStack(spacing: 16) { Image(systemName: "square.stack.3d.up.slash").font(.system(size: 60)).foregroundStyle(.white.opacity(0.2)); Text("Your deck is empty.").font(Orbit.headingFont()).foregroundStyle(.white.opacity(0.5)) }
                            debugSection
                        }; Spacer()
                    } else { ScrollView { LazyVStack(spacing: 16) { ForEach(items) { itemRow(for: $0) }; debugSection } }.scrollDismissesKeyboard(.interactively) }
                }
                ControlBar(text: $newOptionText, focusState: $isInputFocused, onAdd: addOption, onShuffle: {})
            }
            .padding(16).blur(radius: showClearConfirmation ? 10 : 0).animation(Orbit.Dynamics.element, value: showClearConfirmation)
            
            if showClearConfirmation {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea().transition(.opacity).onTapGesture { withAnimation(Orbit.Dynamics.panel) { showClearConfirmation = false } }
                    VStack(spacing: 24) {
                        VStack(spacing: 8) { Text("Clear Deck?").font(Orbit.headingFont()); Text("This will remove all options permanently.").font(Orbit.bodyFont()).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.7)) }
                        VStack(spacing: 12) {
                            Button(action: { withAnimation(Orbit.Dynamics.panel) { items.removeAll(); showClearConfirmation = false; Haptics.shared.selectionRemoved() } }) { Text("Clear All").font(Orbit.bodyFont()).foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 50).background(Color.red.opacity(0.8)).clipShape(Capsule()) }
                            Button(action: { withAnimation(Orbit.Dynamics.panel) { showClearConfirmation = false } }) { Text("Cancel").font(Orbit.bodyFont()).foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 50).background(Orbit.glassMaterial).clipShape(Capsule()).overlay(Capsule().stroke(Orbit.glassBorder, lineWidth: Orbit.glassBorderWidth)) }
                        }
                    }
                    .padding(24).background(Orbit.glassMaterial).clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(Orbit.glassBorder, lineWidth: Orbit.glassBorderWidth)).padding(.horizontal, 40).transition(.scale(scale: 0.9).combined(with: .opacity)).zIndex(10)
                }
            }
        }
        .preferredColorScheme(.dark).onAppear { usedSessionColors.removeAll() }
    }

    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DEVELOPER SETTINGS").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(.white.opacity(0.3)).padding(.leading, 12)
            HStack {
                Image(systemName: "eye.fill").foregroundStyle(Theme.color(for: "denim"))
                Text("Show Onboarding").font(Orbit.bodyFont()).foregroundStyle(.white); Spacer()
                Toggle("", isOn: Binding(get: { !hasSeenOnboarding }, set: { hasSeenOnboarding = !$0 })).labelsHidden().tint(Theme.color(for: "denim"))
            }.padding(.vertical, 16).padding(.horizontal, 20).background(.ultraThinMaterial).clipShape(Capsule()).overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
        }.padding(.top, 24).padding(.horizontal, 4)
    }

    func itemRow(for item: Item) -> some View {
        HStack(spacing: 16) {
            Circle().fill(item.color).frame(width: 22, height: 22).shadow(color: item.color.opacity(0.6), radius: 4)
            Text(item.text).font(Orbit.bodyFont()).foregroundStyle(.white); Spacer()
            Button(action: { withAnimation(Orbit.Dynamics.element) { items.removeAll { $0.id == item.id }; Haptics.shared.selectionRemoved() } }) { Image(systemName: "xmark.circle.fill").font(.system(size: 22)).foregroundStyle(.white.opacity(0.3)) }.buttonStyle(.plain)
        }.padding(.vertical, 16).padding(.horizontal, 20).background(.ultraThinMaterial).clipShape(Capsule()).overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
    }

    func addOption() {
        guard !newOptionText.isEmpty else { return }
        if items.contains(where: { $0.text.localizedCaseInsensitiveCompare(newOptionText) == .orderedSame }) { newOptionText = ""; return }
        let picked = Theme.colorNames.filter { !usedSessionColors.contains($0) }.randomElement() ?? "denim"
        usedSessionColors.insert(picked); withAnimation(Orbit.Dynamics.element) { items.insert(Item(text: newOptionText, colorName: picked), at: 0) }
        newOptionText = ""; isInputFocused = true
    }
}
