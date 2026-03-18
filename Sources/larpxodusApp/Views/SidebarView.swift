import SwiftUI

struct SidebarView: View {
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

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("larpxodus")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                }

                SearchBar(text: $store.searchText)

                PortfolioSummaryCard()

                List(selection: $store.selectedAssetID) {
                    ForEach(store.filteredAssets) { asset in
                        AssetRow(asset: asset)
                            .tag(asset.id)
                            .listRowInsets(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                            .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .padding(22)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search assets", text: $text)
                .textFieldStyle(.plain)
        }
        .padding(12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct PortfolioSummaryCard: View {
    @EnvironmentObject private var store: WalletStore

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Portfolio")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(store.totalBalanceUSD, format: .currency(code: "USD"))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
            }
            Spacer()
            Button(store.isEditingBalances ? "Done" : "Edit") {
                withAnimation(.spring(duration: 0.25)) {
                    store.isEditingBalances.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.93, green: 0.42, blue: 0.21))
        }
        .padding(18)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct AssetRow: View {
    let asset: Asset

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(asset.color.gradient)
                .frame(width: 38, height: 38)
                .overlay {
                    Text(String(asset.symbol.prefix(1)))
                        .font(.headline.bold())
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.headline)
                Text(asset.symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(asset.holdingsValueUSD, format: .currency(code: "USD"))
                    .font(.headline)
                Text("\(asset.dayChangePercent, specifier: "%.2f")%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(asset.dayChangePercent >= 0 ? .green : .red)
            }
        }
        .padding(10)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
