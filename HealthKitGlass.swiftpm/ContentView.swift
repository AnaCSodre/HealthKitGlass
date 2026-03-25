import SwiftUI

struct ContentView: View {
    @Environment(HealthKitViewModel.self) private var viewModel

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "heart.text.square") {
                DashboardView()
            }
            Tab("Passos", systemImage: "figure.walk") {
                StepDetailView()
            }
            Tab("Coração", systemImage: "heart.fill") {
                HeartRateDetailView()
            }
        }
        .task {
            if viewModel.isHealthKitAvailable {
                await viewModel.requestAuthorization()
            } else {
                viewModel.loadSampleData()
            }
        }
    }
}
