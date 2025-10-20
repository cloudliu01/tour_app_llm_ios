import Combine
import Foundation

struct PhotoNarrationRequest: Codable {
    let photoId: String
    let captureTimestamp: Date
    let location: LocationSnapshot
    let language: String
    let voiceProfile: String?
    let deviceState: DeviceState?
    let autoPlayRequested: Bool
    let idempotencyKey: String
}

struct LocationNarrationRequest: Codable {
    let geofenceId: String
    let location: LocationSnapshot
    let language: String
    let voiceProfile: String?
    let autoPlayEligible: Bool
    let headphonesStatus: String
    let idempotencyKey: String
}

struct RegenerationRequest: Codable {
    let command: String
    let language: String?
    let voiceProfile: String?
    let referenceSegmentId: String?
}

struct FeedbackRequest: Codable {
    struct FeedbackItem: Codable {
        let segmentId: String
        let rating: String
        let notes: String?
        let timestamp: Date
    }

    let feedbackItems: [FeedbackItem]
}

struct NarrationThreadDTO: Codable {
    let threadId: String
    let status: String
    let originType: String
    let language: String
    let voiceProfile: String
    let cacheOrigin: String
    let autoPlayEnabled: Bool
    let location: LocationSnapshot
    let segments: [NarrationSegmentDTO]
}

struct NarrationSegmentDTO: Codable {
    let segmentId: String
    let sequenceIndex: Int
    let text: String
    let audioUrl: URL?
    let durationMs: Int?
    let highlightState: String
    let isAudioReady: Bool
    let createdAt: Date
}

struct NarrationStreamEventDTO: Codable {
    let eventType: String
    let payload: Data
    let cursor: String?
}

struct CacheSyncRequestDTO: Codable {
    struct Item: Codable {
        let cacheKey: String
        let scope: String
        let sizeBytes: Int
        let lastAccessed: Date
        let reuseCount: Int
    }

    let deviceId: String
    let totalBytes: Int
    let items: [Item]
}

struct CacheSyncResponseDTO: Codable {
    struct Action: Codable {
        let cacheKey: String
        let directive: String
        let priority: Int
    }

    let actions: [Action]
}

struct LocationSnapshot: Codable {
    let latitude: Double
    let longitude: Double
    let placeName: String?
    let accuracyMeters: Double?
}

struct DeviceState: Codable {
    let networkQuality: String?
    let batteryLevel: Int?
    let headphonesStatus: String?
}

protocol NarrationAPIClientProtocol {
    func submitPhotoNarration(_ request: PhotoNarrationRequest) -> AnyPublisher<NarrationThreadDTO, Error>
    func submitLocationNarration(_ request: LocationNarrationRequest) -> AnyPublisher<NarrationThreadDTO, Error>
    func regenerateNarration(threadId: String, request: RegenerationRequest) -> AnyPublisher<NarrationThreadDTO, Error>
    func sendFeedback(threadId: String, request: FeedbackRequest) -> AnyPublisher<Void, Error>
    func streamNarration(threadId: String, cursor: String?) -> AnyPublisher<NarrationStreamEventDTO, Error>
    func syncCache(_ request: CacheSyncRequestDTO) -> AnyPublisher<CacheSyncResponseDTO, Error>
}

final class NarrationAPIClient: NarrationAPIClientProtocol {
    private let baseURL: URL
    private let urlSession: URLSession

    init(baseURL: URL, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    func submitPhotoNarration(_ request: PhotoNarrationRequest) -> AnyPublisher<NarrationThreadDTO, Error> {
        post("/v1/narrations/photo", requestBody: request)
    }

    func submitLocationNarration(_ request: LocationNarrationRequest) -> AnyPublisher<NarrationThreadDTO, Error> {
        post("/v1/narrations/location", requestBody: request)
    }

    func regenerateNarration(threadId: String, request: RegenerationRequest) -> AnyPublisher<NarrationThreadDTO, Error> {
        post("/v1/narrations/\(threadId)/regenerate", requestBody: request)
    }

    func sendFeedback(threadId: String, request: FeedbackRequest) -> AnyPublisher<Void, Error> {
        post("/v1/narrations/\(threadId)/feedback", requestBody: request)
            .map { (_: NarrationThreadDTO) in () }
            .eraseToAnyPublisher()
    }

    func streamNarration(threadId: String, cursor: String?) -> AnyPublisher<NarrationStreamEventDTO, Error> {
        var components = URLComponents(url: baseURL.appendingPathComponent("/v1/narrations/\(threadId)/stream"), resolvingAgainstBaseURL: false)
        if let cursor {
            components?.queryItems = [URLQueryItem(name: "cursor", value: cursor)]
        }
        guard let url = components?.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { output -> NarrationStreamEventDTO in
                guard let event = try? JSONDecoder().decode(NarrationStreamEventDTO.self, from: output.data) else {
                    throw URLError(.cannotDecodeRawData)
                }
                return event
            }
            .eraseToAnyPublisher()
    }

    func syncCache(_ request: CacheSyncRequestDTO) -> AnyPublisher<CacheSyncResponseDTO, Error> {
        post("/v1/cache/sync", requestBody: request)
    }

    private func post<T: Codable, U: Codable>(_ path: String, requestBody: T) -> AnyPublisher<U, Error> {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return urlSession.dataTaskPublisher(for: request)
            .tryMap { output -> U in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard (200..<300).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(U.self, from: output.data)
            }
            .eraseToAnyPublisher()
    }
}
