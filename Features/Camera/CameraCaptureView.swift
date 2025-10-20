import SwiftUI

struct CameraCaptureView: View {
    @ObservedObject var viewModel: CameraCaptureViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                topBar
                Spacer()
                shutterRow
            }
            .padding(DesignTokens.Layout.standardPadding)
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .sheet(isPresented: $viewModel.isChatPresented) {
            ChatOverlayContainer()
                .presentationDetents([.fraction(0.7), .fraction(0.9)])
        }
    }

    private var topBar: some View {
        HStack {
            Text("Edinburgh Castle • Precise")
                .font(DesignTokens.Typography.body)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
            Spacer()
            Button {
                viewModel.isGalleryPresented.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }

    private var shutterRow: some View {
        HStack {
            Spacer()
            Button {
                viewModel.handleShutter()
            } label: {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 6)
                    .frame(width: 80, height: 80)
            }
            Spacer()
            Button {
                viewModel.isChatPresented.toggle()
            } label: {
                Image(systemName: "ellipsis.message")
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }
}

private struct ChatOverlayContainer: View {
    var body: some View {
        ChatOverlayView(viewModel: ChatOverlayViewModel())
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Layout.cornerRadiusLarge))
            .padding()
    }
}

#Preview {
    CameraCaptureView(
        viewModel: CameraCaptureViewModel(
            captureService: CameraCaptureService(
                narrationClient: NarrationAPIClient(baseURL: URL(string: "https://example.com")!)
            )
        )
    )
    .preferredColorScheme(.dark)
}
