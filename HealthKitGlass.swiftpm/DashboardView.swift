import SwiftUI

struct DashboardView: View {
    @Environment(HealthKitViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    metricsGrid
                    weeklyChartSection
                }
                .padding()
            }
            .navigationTitle("Minha Saúde")
            .refreshable {
                await viewModel.fetchAllData()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red.gradient)
                .symbolEffect(.pulse, options: .repeating)

            Text("Olá, Ana!")
                .font(.title2.bold())

            Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .glassEffect(.regular)
    }

    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            MetricCard(
                title: "Passos",
                value: "\(viewModel.summary.todaySteps.formatted())",
                unit: "passos",
                icon: "figure.walk",
                tint: .blue
            )

            MetricCard(
                title: "Calorias",
                value: String(format: "%.0f", viewModel.summary.todayCalories),
                unit: "kcal",
                icon: "flame.fill",
                tint: .orange
            )

            MetricCard(
                title: "Freq. Cardíaca",
                value: String(format: "%.0f", viewModel.summary.currentHeartRate),
                unit: "bpm",
                icon: "heart.fill",
                tint: .red
            )

            MetricCard(
                title: "Meta Diária",
                value: "\(min(Int(Double(viewModel.summary.todaySteps) / 10000.0 * 100), 100))",
                unit: "%",
                icon: "target",
                tint: .green
            )
        }
    }

    // MARK: - Weekly Chart

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Passos da Semana")
                .font(.headline)

            WeeklyStepsChart(data: viewModel.summary.weeklySteps)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular)
    }
}
