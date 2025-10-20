import Combine
import Foundation

@MainActor
final class ChatOverlayViewModel: ObservableObject {
    struct ChatSegment: Identifiable {
        let id: UUID
        let text: String
        var progress: Double
        var isActive: Bool
    }

    static let playbackSpeeds: [Double] = [0.8, 1.0, 1.25, 1.5]

    @Published private(set) var segments: [ChatSegment] = []
    @Published private(set) var activeSegmentId: UUID?
    @Published private(set) var isPlaying = false
    @Published private(set) var speed: Double = 1.0
    @Published var commandText: String = ""

    private var playbackTimer: AnyCancellable?

    func loadMockSegments() async {
        guard segments.isEmpty else { return }
        segments = [
            ChatSegment(id: UUID(), text: "这是苏格兰诗人罗伯特·彭斯。", progress: 0, isActive: true),
            ChatSegment(id: UUID(), text: "他以浪漫主义诗歌著称。", progress: 0, isActive: false),
            ChatSegment(id: UUID(), text: "现在让我们继续探索城堡的历史。", progress: 0, isActive: false)
        ]
        activeSegmentId = segments.first?.id
        togglePlayPause()
    }

    func togglePlayPause() {
        isPlaying.toggle()
        isPlaying ? startPlayback() : stopPlayback()
    }

    func rewind15Seconds() {
        guard let index = activeIndex else { return }
        segments[index].progress = max(0, segments[index].progress - 0.25)
    }

    func skipSegment() {
        guard let index = activeIndex else { return }
        moveToSegment(at: index + 1)
    }

    func setSpeed(_ newSpeed: Double) {
        speed = newSpeed
        if isPlaying {
            stopPlayback()
            startPlayback()
        }
    }

    func sendCommand() {
        guard !commandText.isEmpty else { return }
        // Placeholder until regeneration API is wired
        commandText = ""
    }

    private var activeIndex: Int? {
        guard let id = activeSegmentId else { return nil }
        return segments.firstIndex { $0.id == id }
    }

    private func startPlayback() {
        playbackTimer = Timer.publish(every: 1.0 / speed, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.advancePlayback()
            }
    }

    private func stopPlayback() {
        playbackTimer?.cancel()
        playbackTimer = nil
    }

    private func advancePlayback() {
        guard let index = activeIndex else { return }
        segments[index].progress += 0.1
        if segments[index].progress >= 1.0 {
            moveToSegment(at: index + 1)
        }
    }

    private func moveToSegment(at newIndex: Int) {
        if let index = activeIndex {
            segments[index].isActive = false
            segments[index].progress = 1.0
        }
        if newIndex < segments.count {
            segments[newIndex].isActive = true
            segments[newIndex].progress = 0
            activeSegmentId = segments[newIndex].id
        } else {
            activeSegmentId = nil
            stopPlayback()
            isPlaying = false
        }
    }
}
