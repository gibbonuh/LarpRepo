import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: WalletStore
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        Group {
            #if os(iOS)
            if horizontalSizeClass == .compact {
                PhoneWalletView()
            } else {
                SharedSplitWalletView()
            }
            #else
            SharedSplitWalletView()
            #endif
        }
        .preferredColorScheme(.dark)
    }
}

private struct SharedSplitWalletView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 300, ideal: 330)
        } detail: {
            DashboardView()
        }
    }
}

#if os(iOS)
private struct PhoneWalletView: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        NavigationStack {
            PhoneAssetListView()
                .navigationTitle("larpxodus")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(store.isEditingBalances ? "Done" : "Edit") {
                            withAnimation(.spring(duration: 0.25)) {
                                store.isEditingBalances.toggle()
                            }
                        }
                    }
                }
        }
    }
}

private struct PhoneAssetListView: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.09, green: 0.10, blue: 0.12),
                    Color(red: 0.05, green: 0.06, blue: 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    SearchBar(text: $store.searchText)
                    PortfolioSummaryCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                List(store.filteredAssets) { asset in
                    NavigationLink {
                        AssetDetailScreen(assetID: asset.id)
                    } label: {
                        AssetRow(asset: asset)
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
    }
}

private struct AssetDetailScreen: View {
    @EnvironmentObject private var store: WalletStore
    let assetID: Asset.ID

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.14, green: 0.11, blue: 0.09),
                    Color(red: 0.07, green: 0.08, blue: 0.10),
                    Color(red: 0.03, green: 0.04, blue: 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if let asset = store.assets.first(where: { $0.id == assetID }) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HeroCard(asset: asset)
                        MockChart(asset: asset)
                        InspectorPanel(asset: asset)
                    }
                    .padding(20)
                }
            } else {
                Text("Asset unavailable")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(store.assets.first(where: { $0.id == assetID })?.symbol ?? "Asset")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif
