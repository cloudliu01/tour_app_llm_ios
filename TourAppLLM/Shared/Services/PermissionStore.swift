import Combine
import Foundation

/// Centralizes user permission preferences, onboarding state, and runtime checks.
@MainActor
final class PermissionStore: ObservableObject {
    enum PermissionStatus: String, Codable, Equatable {
        case unknown
        case granted
        case denied
    }

    @Published var camera: PermissionStatus = .unknown
    @Published var microphone: PermissionStatus = .unknown
    @Published var location: PermissionStatus = .unknown
    @Published var notifications: PermissionStatus = .unknown
    @Published var autoPlayOptIn = false
    @Published var serviceImprovementOptIn = true

    private let storageKey = "com.tourapp.permissions"

    init() {
        loadPersistedState()
    }

    func update(permission: String, status: PermissionStatus) {
        switch permission {
        case "camera": camera = status
        case "microphone": microphone = status
        case "location": location = status
        case "notifications": notifications = status
        default: break
        }
        persistState()
    }

    func toggleAutoPlayOptIn(_ enabled: Bool) {
        autoPlayOptIn = enabled
        persistState()
    }

    func toggleServiceImprovement(_ enabled: Bool) {
        serviceImprovementOptIn = enabled
        persistState()
    }

    private func loadPersistedState() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(StateSnapshot.self, from: data) else { return }
        camera = snapshot.camera
        microphone = snapshot.microphone
        location = snapshot.location
        notifications = snapshot.notifications
        autoPlayOptIn = snapshot.autoPlayOptIn
        serviceImprovementOptIn = snapshot.serviceImprovementOptIn
    }

    private func persistState() {
        let snapshot = StateSnapshot(
            camera: camera,
            microphone: microphone,
            location: location,
            notifications: notifications,
            autoPlayOptIn: autoPlayOptIn,
            serviceImprovementOptIn: serviceImprovementOptIn
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private struct StateSnapshot: Codable {
        let camera: PermissionStatus
        let microphone: PermissionStatus
        let location: PermissionStatus
        let notifications: PermissionStatus
        let autoPlayOptIn: Bool
        let serviceImprovementOptIn: Bool
    }
}
