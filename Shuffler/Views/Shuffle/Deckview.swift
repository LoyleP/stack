import SwiftUI

struct DeckView: View {
    @StateObject private var viewModel = DeckViewModel()
    @EnvironmentObject var store: DeckStore
    
    // UI State
    @State private var newOptionText = ""
    @State private var showInput = false
    @State private var isKeyboardVisible = false
    @State private var isHolding = false
    @State private var isTapping = false
    @State private var lastPressTime: Date = Date()
    @State private var showOptionsDrawer = false
    
    // 0: Saved (Left), 1: Home (Center)
    @State private var selectedPage: Int = 1
    @State private var dragOffset: CGSize = .zero
    
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            // Root background ignores safe area to maintain the "Dark Zone" fix
            Color(red: 0.05, green: 0.06, blue: 0.07).ignoresSafeArea()
            
            TabView(selection: $selectedPage) {
                SavedDecksView(isPresented: .constant(true)) { selectedItems in
                    withAnimation(Orbit.Dynamics.physics) { viewModel.items = selectedItems }
                    viewModel.saveItems()
                    withAnimation(Orbit.Dynamics.panel) { selectedPage = 1 }
                }
                .tag(0)

                homeContent()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            // IMPORTANT: This prevents the system from "snapping" the whole screen up
            .ignoresSafeArea(.keyboard)
            
            pageIndicator
                .padding(.top, 12)
                .zIndex(10)
        }
        .sheet(isPresented: $showOptionsDrawer) {
            OptionsListView(items: $viewModel.items, isPresented: $showOptionsDrawer)
                .environmentObject(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            // Unified manual animation trigger
            withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) { isKeyboardVisible = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) { isKeyboardVisible = false }
        }
        .onShake { viewModel.performShortShuffle() }
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<2) { index in
                Capsule()
                    .fill(selectedPage == index ? Color.white : Color.white.opacity(0.2))
                    .frame(width: selectedPage == index ? 20 : 6, height: 6)
            }
        }
    }
    
    @ViewBuilder
    private func homeContent() -> some View {
        ZStack {
            backgroundLayer
            
            cardLayer
                .offset(y: isKeyboardVisible ? -100 : -20) // Manually lifting cards higher
            
            // Top Right Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        Haptics.shared.play(.light)
                        showOptionsDrawer = true
                    }) {
                        Image(systemName: "list.bullet")
                    }
                    .buttonStyle(.orbitGlass)
                    .padding(.trailing, 20)
                    .padding(.top, 40)
                    .opacity(isKeyboardVisible ? 0 : 1) // Hide when typing to clean UI
                }
                Spacer()
            }
            
            controlLayer
        }
    }

    private var cardLayer: some View {
        ZStack {
            if viewModel.items.isEmpty {
                emptyStateView
            } else {
                SparkleView(trigger: $viewModel.sparkleTrigger).zIndex(-10)
                ForEach(viewModel.items) { item in
                    CardView(text: item.text, color: item.color)
                        .rotationEffect(getRotation(for: item))
                        .offset(getOffset(for: item))
                        .scaleEffect(getScale(for: item))
                        .blur(radius: viewModel.isShuffling ? 6 : 0)
                        .zIndex(item.id == viewModel.activeShuffleId ? 1000 : Double(viewModel.items.firstIndex(where: { $0.id == item.id }) ?? 0))
                        .gesture(item.id == viewModel.items.last?.id && !viewModel.isShuffling ? dragGesture : nil)
                }
            }
        }
        // DEFAULT SCALE set to 0.75 for extra swipe margin
        .scaleEffect(isKeyboardVisible ? 0.6 : 0.75)
    }

    private var controlLayer: some View {
        VStack {
            Spacer()
            if showInput {
                ControlBar(text: $newOptionText, focusState: $isInputFocused, onAdd: { viewModel.addOption(newOptionText); newOptionText = "" }, onShuffle: viewModel.performShortShuffle)
                // Offset the bar by keyboard height manually for the "sticky" feel
                .padding(.bottom, isKeyboardVisible ? 320 : 20)
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                HStack(spacing: 16) {
                    Button(action: { withAnimation(Orbit.Dynamics.element) { showInput = true; isInputFocused = true } }) { Image(systemName: "plus") }.buttonStyle(.orbitGlass)
                    shuffleButton
                }
                .padding(.bottom, 40)
            }
        }
    }

    // (Remaining helper functions like backgroundLayer, shuffleButton, dragGesture, etc. remain the same as previous)
    
    private var backgroundLayer: some View {
        LinearGradient(
            colors: [viewModel.items.last?.color.opacity(0.35) ?? .gray.opacity(0.1), Color(red: 0.05, green: 0.06, blue: 0.07)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(Orbit.Dynamics.background, value: viewModel.items.last?.id)
        .onTapGesture {
            if showInput {
                isInputFocused = false
                hideKeyboard()
                withAnimation(Orbit.Dynamics.panel) { showInput = false }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash").font(.system(size: 60)).foregroundStyle(.white.opacity(0.4))
            Text("No options left.").font(Orbit.headingFont()).foregroundStyle(.white.opacity(0.4))
        }
    }

    private var shuffleButton: some View {
        ZStack {
            Circle().fill(.white).frame(width: 56, height: 56).overlay(ProgressView().tint(.black)).opacity(isTapping ? 1 : 0).scaleEffect(isTapping ? 1 : 0.7)
            HStack { Image(systemName: "shuffle"); Text("Shuffle") }.font(Orbit.headingFont()).foregroundStyle(.black).padding(.horizontal, 30).frame(height: 56).background(Capsule().fill(.white)).opacity(isTapping ? 0 : 1).scaleEffect(isTapping ? 0.8 : 1)
        }
        .scaleEffect(isHolding ? 1.1 : 1.0)
        .gesture(DragGesture(minimumDistance: 0).onChanged { _ in if !viewModel.isShuffling { lastPressTime = Date(); withAnimation(Orbit.Dynamics.gesture) { isHolding = true }; viewModel.startContinuousShuffle() } }
            .onEnded { _ in withAnimation(Orbit.Dynamics.gesture) { isHolding = false }; if Date().timeIntervalSince(lastPressTime) < 0.2 { withAnimation(Orbit.Dynamics.physics) { isTapping = true }; DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { isTapping = false; viewModel.endContinuousShuffle() } } else { viewModel.endContinuousShuffle() } })
        .disabled(viewModel.items.isEmpty)
    }

    private var dragGesture: some Gesture {
        DragGesture().onChanged { v in withAnimation(Orbit.Dynamics.gesture) { dragOffset = v.translation } }
            .onEnded { v in
                if abs(v.translation.width) > 140 {
                    let dir: CGFloat = v.translation.width > 0 ? 1 : -1
                    withAnimation(Orbit.Dynamics.element) { dragOffset.width = 1000 * dir }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        Haptics.shared.shuffleTuck()
                        withAnimation(Orbit.Dynamics.physics) {
                            let card = viewModel.items.removeLast()
                            viewModel.items.insert(card, at: 0)
                            dragOffset = .zero
                        }
                        viewModel.saveItems()
                    }
                } else { withAnimation(Orbit.Dynamics.physics) { dragOffset = .zero } }
            }
    }

    func getOffset(for item: Item) -> CGSize {
        var x = viewModel.cardOffsets[item.id] ?? 0
        var y: CGFloat = 0
        if item.id == viewModel.items.last?.id && !viewModel.isShuffling { x += dragOffset.width; y += dragOffset.height }
        return CGSize(width: x, height: y)
    }

    func getRotation(for item: Item) -> Angle {
        var rot = item.rotation
        if item.id == viewModel.items.last?.id && !viewModel.isShuffling { rot += Double(dragOffset.width / 15) }
        if let x = viewModel.cardOffsets[item.id] { rot += Double(x / 18) }
        return .degrees(rot)
    }

    func getScale(for item: Item) -> CGFloat {
        guard let index = viewModel.items.firstIndex(where: { $0.id == item.id }) else { return 1.0 }
        let distanceToTop = viewModel.items.count - 1 - index
        let baseScale = 1.0 - (CGFloat(distanceToTop) * 0.03)
        if item.id == viewModel.items.last?.id && dragOffset != .zero && !viewModel.isShuffling { return baseScale + 0.02 }
        return baseScale
    }

    private func hideKeyboard() { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
}
