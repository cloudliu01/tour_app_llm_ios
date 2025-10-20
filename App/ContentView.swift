import SwiftUI

struct ContentView: View {
    private let captureService = CameraCaptureService(
        narrationClient: NarrationAPIClient(baseURL: URL(string: "https://example.com")!)
    )

    var body: some View {
        CameraCaptureView(
            viewModel: CameraCaptureViewModel(captureService: captureService)
        )
    }
}

#Preview {
    ContentView()
}
