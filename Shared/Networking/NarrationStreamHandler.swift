import Combine
import Foundation

/// Bridges streaming narration events into structured updates for UI consumption.
final class NarrationStreamHandler {
    struct StreamUpdate {
        let segmentId: String
        let eventType: String
        let payload: Data
    }

    private let client: NarrationAPIClientProtocol

    init(client: NarrationAPIClientProtocol) {
        self.client = client
    }

    func stream(threadId: String) -> AnyPublisher<StreamUpdate, Error> {
        client.streamNarration(threadId: threadId, cursor: nil)
            .map { event in
                StreamUpdate(
                    segmentId: event.cursor ?? UUID().uuidString,
                    eventType: event.eventType,
                    payload: event.payload
                )
            }
            .eraseToAnyPublisher()
    }
}
