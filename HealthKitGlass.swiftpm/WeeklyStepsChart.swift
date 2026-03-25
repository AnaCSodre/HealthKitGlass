import SwiftUI
import Charts

struct WeeklyStepsChart: View {
    let data: [StepData]

    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Dia", item.date, unit: .day),
                y: .value("Passos", item.count)
            )
            .foregroundStyle(.blue.gradient)
            .cornerRadius(6)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 180)
    }
}
