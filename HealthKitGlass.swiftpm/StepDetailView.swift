import SwiftUI
import Charts

struct StepDetailView: View {
    @Environment(HealthKitViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todayCard
                    weeklyChart
                    dailyList
                }
                .padding()
            }
            .navigationTitle("Passos")
        }
    }

    // MARK: - Today Card

    private var todayCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.walk.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.blue.gradient)

            Text("\(viewModel.summary.todaySteps.formatted())")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            Text("passos hoje")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(value: min(Double(viewModel.summary.todaySteps) / 10000.0, 1.0))
                .tint(.blue)
                .padding(.horizontal, 30)

            Text("Meta: 10.000 passos")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular)
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Última Semana")
                .font(.headline)

            Chart(viewModel.summary.weeklySteps) { item in
                BarMark(
                    x: .value("Dia", item.date, unit: .day),
                    y: .value("Passos", item.count)
                )
                .foregroundStyle(.blue.gradient)
                .cornerRadius(6)

                RuleMark(y: .value("Meta", 10000))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .foregroundStyle(.secondary)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 200)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular)
    }

    // MARK: - Daily List

    private var dailyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detalhes por Dia")
                .font(.headline)

            ForEach(viewModel.summary.weeklySteps.reversed()) { step in
                HStack {
                    Text(step.date.formatted(.dateTime.weekday(.wide).day().month()))
                        .font(.subheadline)

                    Spacer()

                    Text("\(step.count.formatted()) passos")
                        .font(.subheadline.bold())
                        .foregroundStyle(step.count >= 10000 ? .green : .primary)
                }
                .padding(.vertical, 6)

                if step.id != viewModel.summary.weeklySteps.first?.id {
                    Divider()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular)
    }
}
