import Foundation
import SwiftUI

struct Asset: Identifiable, Hashable {
    let id: UUID
    var symbol: String
    var name: String
    var unitsOwned: Double
    var unitPriceUSD: Double
    var dayChangePercent: Double
    var color: Color

    init(
        id: UUID = UUID(),
        symbol: String,
        name: String,
        unitsOwned: Double,
        unitPriceUSD: Double,
        dayChangePercent: Double,
        color: Color
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.unitsOwned = unitsOwned
        self.unitPriceUSD = unitPriceUSD
        self.dayChangePercent = dayChangePercent
        self.color = color
    }

    var holdingsValueUSD: Double {
        unitsOwned * unitPriceUSD
    }
}
