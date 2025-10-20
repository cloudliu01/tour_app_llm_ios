import SwiftUI

@main
struct TourAppLLMApp: App {
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
        }
    }
}

final class AppCoordinator: ObservableObject {
    @Published var isOnboardingPresented = false
}
