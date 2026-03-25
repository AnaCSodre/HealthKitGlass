import SwiftUI

@main
struct HealthKitGlassApp: App {
    @State private var viewModel = HealthKitViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
