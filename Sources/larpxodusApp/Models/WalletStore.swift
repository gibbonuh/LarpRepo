import Foundation
import SwiftUI

final class WalletStore: ObservableObject {
    @Published var assets: [Asset]
    @Published var selectedAssetID: Asset.ID?
    @Published var searchText = ""
    @Published var isEditingBalances = false

    init(assets: [Asset]) {
        self.assets = assets
        self.selectedAssetID = assets.first?.id
    }

    var selectedAsset: Asset? {
        get { assets.first(where: { $0.id == selectedAssetID }) }
        set {
            guard let newValue, let index = assets.firstIndex(where: { $0.id == newValue.id }) else { return }
            assets[index] = newValue
        }
    }

    var filteredAssets: [Asset] {
        guard !searchText.isEmpty else { return assets }
        return assets.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }

    var totalBalanceUSD: Double {
        assets.reduce(0) { $0 + $1.holdingsValueUSD }
    }

    var totalDayChangeValue: Double {
        assets.reduce(0) { partial, asset in
            partial + (asset.holdingsValueUSD * asset.dayChangePercent / 100)
        }
    }

    func update(assetID: Asset.ID, unitsOwned: Double, unitPriceUSD: Double, dayChangePercent: Double) {
        guard let index = assets.firstIndex(where: { $0.id == assetID }) else { return }
        assets[index].unitsOwned = unitsOwned
        assets[index].unitPriceUSD = unitPriceUSD
        assets[index].dayChangePercent = dayChangePercent
    }

    static let sample = WalletStore(
        assets: [
            Asset(symbol: "BTC", name: "Bitcoin", unitsOwned: 1.4821, unitPriceUSD: 67730.49, dayChangePercent: 1.4, color: Color(red: 0.97, green: 0.57, blue: 0.16)),
            Asset(symbol: "ETH", name: "Ethereum", unitsOwned: 18.327, unitPriceUSD: 2034.27, dayChangePercent: 1.7, color: Color(red: 0.33, green: 0.45, blue: 0.96)),
            Asset(symbol: "SOL", name: "Solana", unitsOwned: 525.11, unitPriceUSD: 76.75, dayChangePercent: -1.3, color: Color(red: 0.17, green: 0.79, blue: 0.64)),
            Asset(symbol: "AVAX", name: "Avalanche", unitsOwned: 913.0, unitPriceUSD: 9.49, dayChangePercent: -0.6, color: Color(red: 0.89, green: 0.21, blue: 0.28)),
            Asset(symbol: "USDC", name: "USD Coin", unitsOwned: 20500.0, unitPriceUSD: 0.9999, dayChangePercent: 0.0, color: Color(red: 0.18, green: 0.49, blue: 0.93))
        ]
    )
}
