import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: WalletStore

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

            if let asset = store.selectedAsset {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HeroCard(asset: asset)
                        MockChart(asset: asset)
                        InspectorPanel(asset: asset)
                    }
                    .padding(28)
                }
            } else {
                ContentUnavailableView("No asset selected", systemImage: "bitcoinsign.circle")
            }
        }
    }
}

struct HeroCard: View {
    @EnvironmentObject private var store: WalletStore
    let asset: Asset

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(asset.name)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Text(asset.symbol)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                BalancePill(title: "24h", value: asset.dayChangePercent, isPercent: true)
            }

            HStack(alignment: .bottom) {
                Text(asset.holdingsValueUSD, format: .currency(code: "USD"))
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text(asset.unitsOwned.formatted(.number.precision(.fractionLength(4))))
                        .font(.title2.bold())
                    Text("coins held")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 14) {
                StatLine(label: "Total wallet", value: store.totalBalanceUSD, color: .secondary)
                StatLine(
                    label: "Portfolio move",
                    value: store.totalDayChangeValue,
                    color: store.totalDayChangeValue >= 0 ? .green : .red
                )
            }
            .font(.headline)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            asset.color.opacity(0.7),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct StatLine: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
            Text(value, format: .currency(code: "USD"))
        }
        .foregroundStyle(color)
    }
}

struct MockChart: View {
    let asset: Asset

    private var points: [CGFloat] {
        let base: [CGFloat] = [0.55, 0.48, 0.63, 0.58, 0.71, 0.68, 0.83, 0.79]
        return asset.dayChangePercent >= 0 ? base : base.reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance")
                .font(.title2.bold())

            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                let step = width / CGFloat(max(points.count - 1, 1))

                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * (1 - points[0])))
                    for index in points.indices.dropFirst() {
                        path.addLine(to: CGPoint(x: step * CGFloat(index), y: height * (1 - points[index])))
                    }
                }
                .stroke(asset.color, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))

                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    for index in points.indices {
                        path.addLine(to: CGPoint(x: step * CGFloat(index), y: height * (1 - points[index])))
                    }
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(asset.color.opacity(0.15))
            }
            .frame(height: 220)
        }
        .padding(24)
        .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct InspectorPanel: View {
    @EnvironmentObject private var store: WalletStore
    let asset: Asset

    @State private var unitsOwnedText = ""
    @State private var unitPriceText = ""
    @State private var dayChangeText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Balance controls")
                        .font(.title2.bold())
                    Text("Directly edit holdings and USD pricing.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(store.isEditingBalances ? "Unlocked" : "Locked")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background((store.isEditingBalances ? Color.green : Color.gray).opacity(0.16), in: Capsule())
            }

            HStack(spacing: 16) {
                EditorField(title: "Coins", text: $unitsOwnedText, isEnabled: store.isEditingBalances)
                EditorField(title: "Unit Price", text: $unitPriceText, isEnabled: store.isEditingBalances)
                EditorField(title: "24h Change", text: $dayChangeText, isEnabled: store.isEditingBalances)
            }

            HStack {
                Text("Displayed value: \(asset.holdingsValueUSD, format: .currency(code: "USD"))")
                    .font(.headline)
                Spacer()
                Button("Apply Changes") {
                    apply()
                }
                .disabled(!store.isEditingBalances)
                .buttonStyle(.borderedProminent)
                .tint(asset.color)
            }
        }
        .padding(24)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .onAppear(perform: syncFields)
        .onChange(of: asset.id) { _, _ in
            syncFields()
        }
    }

    private func syncFields() {
        unitsOwnedText = asset.unitsOwned.formatted(.number.precision(.fractionLength(4)))
        unitPriceText = asset.unitPriceUSD.formatted(.number.precision(.fractionLength(2)))
        dayChangeText = asset.dayChangePercent.formatted(.number.precision(.fractionLength(2)))
    }

    private func apply() {
        let units = Double(unitsOwnedText) ?? asset.unitsOwned
        let price = Double(unitPriceText) ?? asset.unitPriceUSD
        let change = Double(dayChangeText) ?? asset.dayChangePercent
        store.update(assetID: asset.id, unitsOwned: units, unitPriceUSD: price, dayChangePercent: change)
    }
}

struct EditorField: View {
    let title: String
    @Binding var text: String
    let isEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            TextField(title, text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .disabled(!isEnabled)
        }
    }
}

struct BalancePill: View {
    let title: String
    let value: Double
    let isPercent: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            Text(
                isPercent
                ? value.formatted(.number.precision(.fractionLength(2))) + "%"
                : value.formatted(.number.precision(.fractionLength(2)))
            )
            .font(.headline.bold())
            .foregroundStyle(value >= 0 ? .green : .red)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
