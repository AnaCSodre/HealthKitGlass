import SwiftUI

struct ContentView: View {
    @Environment(HealthKitViewModel.self) private var viewModel

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "heart.text.square") {
                DashboardView()
                    .environment(viewModel)
            }
            Tab("Passos", systemImage: "figure.walk") {
                StepDetailView()
                    .environment(viewModel)
            }
            Tab("Coração", systemImage: "heart.fill") {
                HeartRateDetailView()
                    .environment(viewModel)
            }
        }
        .onAppear {
            #if targetEnvironment(simulator)
            viewModel.loadSampleData()
            #endif
        }
        .task {
            #if !targetEnvironment(simulator)
            if viewModel.isHealthKitAvailable {
                await viewModel.requestAuthorization()
            } else {
                viewModel.loadSampleData()
            }
            #endif
        }
    }
}

#Preview {
    let viewModel = HealthKitViewModel()
    viewModel.loadSampleData()
    return ContentView()
        .environment(viewModel)
}
