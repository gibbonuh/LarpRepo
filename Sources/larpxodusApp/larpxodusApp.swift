import SwiftUI

@main
struct larpxodusApp: App {
    @StateObject private var store = WalletStore.sample

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        #if os(macOS)
        .defaultSize(width: 1180, height: 760)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        #endif
    }
}
