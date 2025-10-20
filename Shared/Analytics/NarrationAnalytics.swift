import Combine
import Foundation

struct NarrationAnalyticsEvent {
    let name: String
    let parameters: [String: Any]
}

protocol NarrationAnalyticsSink {
    func track(_ event: NarrationAnalyticsEvent)
}

final class NarrationAnalytics {
    static let shared = NarrationAnalytics()

    private var sinks: [NarrationAnalyticsSink] = []

    func addSink(_ sink: NarrationAnalyticsSink) {
        sinks.append(sink)
    }

    func trackCaptureStarted(photoId: String, requestId: String) {
        emit(name: "capture_start", params: ["photo_id": photoId, "request_id": requestId])
    }

    func trackNarrationReady(threadId: String, origin: String, durationMs: Int) {
        emit(name: "narration_ready", params: ["thread_id": threadId, "origin": origin, "duration_ms": durationMs])
    }

    func trackPlaybackEvent(threadId: String, segmentId: String, action: String) {
        emit(name: "playback_event", params: ["thread_id": threadId, "segment_id": segmentId, "action": action])
    }

    func trackFeedback(threadId: String, segmentId: String, rating: String) {
        emit(name: "feedback", params: ["thread_id": threadId, "segment_id": segmentId, "rating": rating])
    }

    func trackCacheSync(totalBytes: Int) {
        emit(name: "cache_sync", params: ["total_bytes": totalBytes])
    }

    func trackAutoPlayAttempt(threadId: String, status: String) {
        emit(name: "autoplay_attempt", params: ["thread_id": threadId, "status": status])
    }

    private func emit(name: String, params: [String: Any]) {
        let event = NarrationAnalyticsEvent(name: name, parameters: params)
        sinks.forEach { $0.track(event) }
    }
}
