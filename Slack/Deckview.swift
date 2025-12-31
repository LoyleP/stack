import SwiftUI

struct DeckView: View {
    @State var items: [Item] = {
        if let data = UserDefaults.standard.data(forKey: "savedItems"),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            return decoded
        }
        // Logic: [Bottom Card, ..., Top Card]
        return [Item(text: "Non", colorName: "terracotta"), Item(text: "Oui", colorName: "denim")]
    }()
    
    @State private var newOptionText = ""
    @State private var showInput = false
    @State private var showList = false
    @State private var isShuffling = false
    @State private var sparkleTrigger = 0
    @State private var isKeyboardVisible = false
    @State private var usedSessionColors: Set<String> = []
    
    // Manual Gesture State
    @State private var dragOffset: CGSize = .zero
    
    // NEW: Individual card offsets for the "Swing and Tuck" shuffle
    @State private var cardOffsets: [UUID: CGFloat] = [:]
    
    @State private var isHolding = false
    @State private var isTapping = false
    @State private var shuffleTimer: Timer? = nil
    @State private var originalTopId: UUID? = nil
    @State private var lastPressTime: Date = Date()
    
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            backgroundLayer
            cardLayer
            headerLayer
            controlLayer
        }
        .sheet(isPresented: $showList) {
            OptionsListView(items: $items)
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in isKeyboardVisible = true }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in isKeyboardVisible = false }
        .onChange(of: items) { _, _ in saveItems() }
        .onShake { performShortShuffle() }
    }
    
    // --- LAYERS ---

    private var backgroundLayer: some View {
        // Tweak: Background now tracks the TOP card (last in array)
        LinearGradient(
            colors: [
                items.last?.color.opacity(0.35) ?? .gray.opacity(0.1),
                Color(red: 0.05, green: 0.06, blue: 0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.8), value: items.last?.id)
        .onTapGesture { if showInput { isInputFocused = false; hideKeyboard(); withAnimation { showInput = false } } }
    }

    private var cardLayer: some View {
        ZStack {
            if items.isEmpty {
                emptyStateView
            } else {
                SparkleView(trigger: $sparkleTrigger).zIndex(-10)
                
                // Render from first to last (last is on top)
                ForEach(items) { item in
                    CardView(text: item.text, color: item.color)
                        .rotationEffect(getRotation(for: item))
                        .offset(getOffset(for: item))
                        .scaleEffect(getScale(for: item))
                        .blur(radius: isShuffling ? 10 : 0)
                        // Gesture only enabled for the top card (last item)
                        .gesture(item.id == items.last?.id ? dragGesture : nil)
                }
            }
        }
        .scaleEffect(isKeyboardVisible ? 0.7 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isKeyboardVisible)
        .ignoresSafeArea(.keyboard)
        // Spring handling the front-to-back cycling
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: items.map { $0.id })
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash").font(.system(size: 60)).foregroundStyle(.white.opacity(0.4))
            Text("No options left.").font(Orbit.headingFont()).foregroundStyle(.white.opacity(0.4))
        }
    }

    // --- REFACTORED GEOMETRY ---

    func getOffset(for item: Item) -> CGSize {
        var x = cardOffsets[item.id] ?? 0
        var y: CGFloat = 0
        
        if item.id == items.last?.id {
            x += dragOffset.width
            y += dragOffset.height
        }
        
        return CGSize(width: x, height: y) // Fixed labels
    }

    func getRotation(for item: Item) -> Angle {
        var rot = item.rotation
        if item.id == items.last?.id {
            rot += Double(dragOffset.width / 15)
        }
        // Add swing rotation
        if let x = cardOffsets[item.id] {
            rot += Double(x / 20)
        }
        return .degrees(rot)
    }

    func getScale(for item: Item) -> CGFloat {
        // Determine position from top (last item)
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return 1.0 }
        let distanceToTop = items.count - 1 - index
        
        let baseScale = 1.0 - (CGFloat(distanceToTop) * 0.03)
        if item.id == items.last?.id && dragOffset != .zero { return baseScale + 0.02 }
        return baseScale
    }

    // --- LOGIC: THE SWING AND TUCK SHUFFLE ---

    func startContinuousShuffle() {
        guard !items.isEmpty && !isShuffling else { return }
        originalTopId = items.last?.id
        
        withAnimation(.interactiveSpring()) { dragOffset = .zero }
        withAnimation(.easeInOut(duration: 0.2)) { isShuffling = true }
        Haptics.shared.play(.medium)

        shuffleTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            guard let topItem = items.last else { return }
            let id = topItem.id
            
            // 1. Swing current top card to the right
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                cardOffsets[id] = 400
            }
            
            // 2. Mid-swing: Move to bottom of array (front of list)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                Haptics.shared.play(.light)
                let card = items.removeLast()
                items.insert(card, at: 0)
                
                // 3. Snap back to center while at the bottom
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    cardOffsets[id] = 0
                }
            }
        }
    }

    func endContinuousShuffle() {
        guard isShuffling else { return }
        shuffleTimer?.invalidate(); shuffleTimer = nil
        Haptics.shared.play(.heavy)

        let candidates = items.filter { $0.id != originalTopId }
        let winner = (candidates.randomElement() ?? items.randomElement())!
        var remaining = items.filter { $0.id != winner.id }; remaining.shuffle()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            items = remaining + [winner] // Winner is last (top)
            isShuffling = false; isTapping = false
            cardOffsets.removeAll()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { sparkleTrigger += 1 }
    }

    // --- MANUAL GESTURE ---

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring()) { dragOffset = value.translation }
            }
            .onEnded { value in
                let threshold: CGFloat = 140
                if abs(value.translation.width) > threshold {
                    let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        dragOffset.width = 1000 * direction
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        Haptics.shared.play(.light)
                        let card = items.removeLast()
                        items.insert(card, at: 0)
                        dragOffset = .zero
                    }
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { dragOffset = .zero }
                }
            }
    }

    // --- UI COMPONENTS ---
    
    private var controlLayer: some View {
        VStack {
            Spacer()
            if showInput {
                ControlBar(text: $newOptionText, focusState: $isInputFocused, onAdd: addOption, onShuffle: performShortShuffle)
                    .padding(.bottom, 10).padding(.horizontal, 16).transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                HStack(spacing: 16) {
                    Button(action: { withAnimation { usedSessionColors.removeAll(); showInput = true; isInputFocused = true } }) { Image(systemName: "plus") }
                        .buttonStyle(.orbitGlass)
                    
                    ZStack {
                        Circle().fill(.white).frame(width: 56, height: 56).overlay(ProgressView().tint(.black))
                            .opacity(isTapping ? 1 : 0).scaleEffect(isTapping ? 1 : 0.7)
                        
                        HStack { Image(systemName: "shuffle"); Text("Shuffle") }
                            .font(Orbit.headingFont()).foregroundStyle(.black)
                            .padding(.horizontal, 30).frame(height: 56).background(Capsule().fill(.white))
                            .opacity(isTapping ? 0 : 1).scaleEffect(isTapping ? 0.8 : 1)
                    }
                    .scaleEffect(isHolding ? 1.1 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isTapping)
                    .animation(Orbit.touch, value: isHolding)
                    .contentShape(Capsule())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isShuffling {
                                    lastPressTime = Date()
                                    withAnimation(Orbit.touch) { isHolding = true }
                                    startContinuousShuffle()
                                }
                            }
                            .onEnded { _ in
                                withAnimation(Orbit.touch) { isHolding = false }
                                if Date().timeIntervalSince(lastPressTime) < 0.2 {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isTapping = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { endContinuousShuffle() }
                                } else { endContinuousShuffle() }
                            }
                    )
                    .disabled(items.isEmpty)
                }
                .padding(.bottom, 20)
            }
        }
    }

    private var headerLayer: some View {
        VStack { HStack { Button(action: { showList = true }) { Image(systemName: "list.bullet") }.buttonStyle(.orbitGlass); Spacer() }.padding(.horizontal, 20).padding(.top, 8); Spacer() }.ignoresSafeArea(.keyboard)
    }

    func performShortShuffle() {
        withAnimation { isTapping = true }
        startContinuousShuffle(); DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { endContinuousShuffle() }
    }

    func addOption() {
        guard !newOptionText.isEmpty else { return }
        if items.contains(where: { $0.text.lowercased() == newOptionText.lowercased() }) { newOptionText = ""; return }
        let available = Theme.colorNames.filter { !usedSessionColors.contains($0) }
        let picked = (available.isEmpty ? Theme.colorNames : available).randomElement() ?? "denim"
        usedSessionColors.insert(picked)
        // Add new items to the END (Top of stack)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            items.append(Item(text: newOptionText, colorName: picked))
        }
        newOptionText = ""; isInputFocused = true
    }
    
    func hideKeyboard() { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
    func saveItems() { if let data = try? JSONEncoder().encode(items) { UserDefaults.standard.set(data, forKey: "savedItems") } }
}
