import SwiftUI

struct ChatOverlayView: View {
    @StateObject var viewModel: ChatOverlayViewModel

    init(viewModel: ChatOverlayViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            handleBar
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.segments) { segment in
                            NarrationBubble(segment: segment)
                                .id(segment.id)
                                .onTapGesture {
                                    NarrationAnalytics.shared.trackPlaybackEvent(
                                        threadId: "mock-thread",
                                        segmentId: segment.id.uuidString,
                                        action: "tap"
                                    )
                                }
                        }
                    }
                    .padding()
                }
                .background(DesignTokens.ColorPalette.background.opacity(0.9))
                .onChange(of: viewModel.activeSegmentId) { id in
                    guard let id else { return }
                    withAnimation {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
            playbackControls
            commandBar
        }
        .background(.ultraThinMaterial)
        .cornerRadius(DesignTokens.Layout.cornerRadiusLarge)
        .padding()
        .task { await viewModel.loadMockSegments() }
    }

    private var handleBar: some View {
        Capsule()
            .fill(Color.white.opacity(0.6))
            .frame(width: 40, height: 5)
            .padding(.top, 12)
    }

    private var playbackControls: some View {
        HStack(spacing: 24) {
            Button { viewModel.togglePlayPause() } label: {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .frame(width: 44, height: 44)
            }
            Button { viewModel.rewind15Seconds() } label: {
                Image(systemName: "gobackward.15")
            }
            Button { viewModel.skipSegment() } label: {
                Image(systemName: "forward.end")
            }
            Menu {
                ForEach(ChatOverlayViewModel.playbackSpeeds, id: \.self) { speed in
                    Button("\(speed, specifier: "%.2fx")") { viewModel.setSpeed(speed) }
                }
            } label: {
                Text("\(viewModel.speed, specifier: "%.2fx")")
            }
        }
        .buttonStyle(.borderedProminent)
        .padding(.vertical, 16)
    }

    private var commandBar: some View {
        HStack {
            TextField("输入指令…", text: $viewModel.commandText)
                .textFieldStyle(.roundedBorder)
            Button("Send") {
                viewModel.sendCommand()
                NarrationAnalytics.shared.trackFeedback(
                    threadId: "mock-thread",
                    segmentId: UUID().uuidString,
                    rating: "useful"
                )
            }
            .buttonStyle(.bordered)
        }
        .padding([.horizontal, .bottom])
    }
}

private struct NarrationBubble: View {
    let segment: ChatOverlayViewModel.ChatSegment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(segment.text)
                .font(DesignTokens.Typography.body)
            if segment.isActive {
                ProgressView(value: segment.progress)
            }
        }
        .padding()
        .background(
            segment.isActive
                ? AnyShapeStyle(DesignTokens.ColorPalette.primary.opacity(0.15))
                : AnyShapeStyle(Material.ultraThin)
        )
        .cornerRadius(DesignTokens.Layout.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Layout.cornerRadiusMedium)
                .stroke(segment.isActive ? DesignTokens.ColorPalette.primary : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    ChatOverlayView(viewModel: ChatOverlayViewModel())
        .preferredColorScheme(.dark)
}
