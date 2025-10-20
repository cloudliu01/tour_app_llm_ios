import AVFoundation
import Combine
import CoreLocation
import Foundation

// Conform to @unchecked Sendable because instances are used from @Sendable closures
// dispatched onto a dedicated serial queue (`queue`). Access to mutable state is
// either confined to that queue or performed on the main actor (e.g., updates to
// `latestPhotoURL`). This silences captures of `self` in DispatchQueue.async closures
// while keeping behavior safe in practice.
final class CameraCaptureService: NSObject, ObservableObject, @unchecked Sendable {
    enum CaptureError: Error {
        case cameraUnavailable
        case captureFailed
        case authorizationDenied
    }

    @Published private(set) var latestPhotoURL: URL?

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "com.tourapp.camera")
    private let narrationClient: NarrationAPIClientProtocol
    private var cancellables: Set<AnyCancellable> = []
    private var isConfigured = false

    init(narrationClient: NarrationAPIClientProtocol) {
        self.narrationClient = narrationClient
        super.init()
    }

    func configureSession() throws {
        guard !isConfigured else { return }
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(for: .video) else {
            throw CaptureError.cameraUnavailable
        }

        let input = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }

        session.commitConfiguration()
        isConfigured = true
    }

    func startSession() {
        guard isConfigured else { return }
        queue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stopSession() {
        queue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func capturePhoto(language: String, voiceProfile: String?) async throws {
        guard isConfigured else {
            throw CaptureError.cameraUnavailable
        }
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            throw CaptureError.authorizationDenied
        }

        let delegate = PhotoCaptureDelegate()
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: delegate)
        guard let data = try await delegate.result else {
            throw CaptureError.captureFailed
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".jpg")
        try data.write(to: tempURL)
        await MainActor.run { [tempURL] in
            self.latestPhotoURL = tempURL
        }

        let requestId = UUID().uuidString
        NarrationAnalytics.shared.trackCaptureStarted(photoId: tempURL.lastPathComponent, requestId: requestId)

        let snapshot = await currentLocationSnapshot()
        let request = PhotoNarrationRequest(
            photoId: tempURL.lastPathComponent,
            captureTimestamp: Date(),
            location: snapshot,
            language: language,
            voiceProfile: voiceProfile,
            deviceState: DeviceState(networkQuality: nil, batteryLevel: nil, headphonesStatus: nil),
            autoPlayRequested: false,
            idempotencyKey: requestId
        )

        narrationClient.submitPhotoNarration(request)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    CrashlyticsBridge.record(error: error)
                }
            }, receiveValue: { thread in
                let duration = thread.segments.first?.durationMs ?? 0
                NarrationAnalytics.shared.trackNarrationReady(
                    threadId: thread.threadId,
                    origin: thread.cacheOrigin,
                    durationMs: duration
                )
            })
            .store(in: &cancellables)
    }

    private func currentLocationSnapshot() async -> LocationSnapshot {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        let coordinate = manager.location?.coordinate
        return LocationSnapshot(
            latitude: coordinate?.latitude ?? 0,
            longitude: coordinate?.longitude ?? 0,
            placeName: nil,
            accuracyMeters: manager.location?.horizontalAccuracy
        )
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private var continuation: CheckedContinuation<Data?, Error>?

    var result: Data? {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            continuation?.resume(throwing: error)
        } else {
            continuation?.resume(returning: photo.fileDataRepresentation())
        }
        continuation = nil
    }
}
