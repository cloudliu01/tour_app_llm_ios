import Combine
import SwiftUI

@MainActor
final class CameraCaptureViewModel: ObservableObject {
    @Published var isChatPresented = false
    @Published var isGalleryPresented = false

    private let captureService: CameraCaptureService

    init(captureService: CameraCaptureService) {
        self.captureService = captureService
    }

    func onAppear() {
        Task {
            try? captureService.configureSession()
            captureService.startSession()
        }
    }

    func onDisappear() {
        captureService.stopSession()
    }

    func handleShutter() {
        Task {
            try? await captureService.capturePhoto(language: "zh-CN", voiceProfile: "cn-default")
            isChatPresented = true
        }
    }
}
