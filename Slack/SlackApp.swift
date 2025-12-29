import SwiftUI

@main
struct SlackApp: App {
    var body: some Scene {
        WindowGroup {
            DeckView() // <--- We changed this!
        }
    }
}
