import SwiftUI
import Charts

struct HeartRateDetailView: View {
    @Environment(HealthKitViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    currentBPMCard
                    heartRateChart
                    statsSection
                }
                .padding()
            }
            .navigationTitle("Freq. Cardíaca")
        }
    }

    // MARK: - Current BPM

    private var currentBPMCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 44))
                .foregroundStyle(.red.gradient)
                .symbolEffect(.pulse, options: .repeating)

            Text(String(format: "%.0f", viewModel.summary.currentHeartRate))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.red)
                .contentTransition(.numericText())

            Text("bpm atual")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 30) {
                bpmStat(label: "Mín", value: minBPM)
                bpmStat(label: "Méd", value: avgBPM)
                bpmStat(label: "Máx", value: maxBPM)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular.interactive)
    }

    private func bpmStat(label: String, value: Double) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(String(format: "%.0f", value))
                .font(.title3.bold())
        }
    }

    // MARK: - Chart

    private var heartRateChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Histórico Recente")
                .font(.headline)

            Chart(viewModel.summary.recentHeartRates.reversed()) { item in
                LineMark(
                    x: .value("Hora", item.date),
                    y: .value("BPM", item.bpm)
                )
                .foregroundStyle(.red.gradient)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Hora", item.date),
                    y: .value("BPM", item.bpm)
                )
                .foregroundStyle(.red.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: (minBPM - 10)...(maxBPM + 10))
            .frame(height: 200)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.interactive)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informações")
                .font(.headline)

            infoRow(icon: "heart.circle", label: "Zona atual", value: heartRateZone)
            Divider()
            infoRow(icon: "clock", label: "Última leitura", value: lastReadingTime)
            Divider()
            infoRow(icon: "chart.line.uptrend.xyaxis", label: "Leituras recentes", value: "\(viewModel.summary.recentHeartRates.count)")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.interactive)
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.red)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)

            Spacer()

            Text(value)
                .font(.subheadline.bold())
        }
    }

    // MARK: - Computed

    private var minBPM: Double {
        viewModel.summary.recentHeartRates.map(\.bpm).min() ?? 0
    }

    private var maxBPM: Double {
        viewModel.summary.recentHeartRates.map(\.bpm).max() ?? 0
    }

    private var avgBPM: Double {
        let rates = viewModel.summary.recentHeartRates
        guard !rates.isEmpty else { return 0 }
        return rates.map(\.bpm).reduce(0, +) / Double(rates.count)
    }

    private var heartRateZone: String {
        let bpm = viewModel.summary.currentHeartRate
        switch bpm {
        case ..<60: return "Repouso"
        case 60..<100: return "Normal"
        case 100..<140: return "Moderada"
        case 140..<170: return "Intensa"
        default: return "Máxima"
        }
    }

    private var lastReadingTime: String {
        guard let last = viewModel.summary.recentHeartRates.first else { return "—" }
        return last.date.formatted(.dateTime.hour().minute())
    }
}
