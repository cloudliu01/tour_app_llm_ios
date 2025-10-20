import SwiftUI

struct ContentView: View {
    @State private var locationType: LocationType = .precise
    @State private var isDrawerOpen = false
    @State private var isChatOpen = false
    @State private var isProcessing = false
    @State private var currentStep = 0
    @State private var isDark = false

    private let steps = ["Upload", "Match", "Generate", "TTS"]

    var body: some View {
        GeometryReader { proxy in
            let rawWidth = proxy.size.width - 32
            let layoutWidth = rawWidth > 0 ? min(rawWidth, 380) : proxy.size.width * 0.9

            ZStack {
                backgroundPreview
                    .overlay(Color.black.opacity(0.3))

                VStack(spacing: 16) {
                    LocationPillView(
                        location: "Paris, France",
                        type: locationType,
                        onToggle: toggleLocationType
                    )

                    if isProcessing {
                        ProgressStepsView(steps: steps, currentIndex: currentStep)
                            .transition(.opacity)
                    }
                }
                .frame(width: layoutWidth)
                .padding(.top, 24)
                .frame(maxWidth: .infinity, alignment: .top)

                CameraControlsView(
                    onCapture: handleCapture,
                    onGallery: { print("Open gallery") },
                    onChat: { isChatOpen = true }
                )
                .frame(width: layoutWidth)
                .padding(.bottom, 32)
                .frame(maxHeight: .infinity, alignment: .bottom)

                SlideOutDrawerView(isOpen: isDrawerOpen, onToggle: { isDrawerOpen.toggle() })

                if isChatOpen {
                    chatOverlay
                }

                Button(action: { isDark.toggle() }) {
                    Text(isDark ? "☀️ Light" : "🌙 Dark")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Material.ultraThin)
                        .clipShape(Capsule())
                }
                .frame(width: layoutWidth)
                .padding(.top, 118)
                .frame(maxWidth: .infinity, alignment: .top)

                let handleSize: CGFloat = 46
                let handleMargin: CGFloat = 16
                Button(action: { isDrawerOpen.toggle() }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Material.ultraThin)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 2)
                }
                .frame(width: handleSize, height: handleSize)
                .position(
                    x: proxy.size.width - handleSize / 2 - handleMargin,
                    y: proxy.size.height / 2
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(Color.black)
        }
        .ignoresSafeArea()
        .preferredColorScheme(isDark ? .dark : .light)
    }

    private var backgroundPreview: some View {
        AsyncImage(
            url: URL(string: "https://images.unsplash.com/photo-1760637627329-9e6c79f4aaf7?auto=format&fit=crop&w=1200&q=80")
        ) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.black
        }
        .ignoresSafeArea()
    }

    private func toggleLocationType() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            locationType.toggle()
        }
    }

    private func handleCapture() {
        guard !isProcessing else { return }
        isProcessing = true
        currentStep = 0

        let intervals: [TimeInterval] = [1.0, 1.5, 2.0, 2.5]
        for (index, delay) in intervals.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = index + 1
                }
                if index == intervals.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation { isProcessing = false }
                        isChatOpen = true
                    }
                }
            }
        }
    }

    private var chatOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isChatOpen = false }
                }

            ChatOverlayView(viewModel: ChatOverlayViewModel())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

private enum LocationType: String {
    case precise = "Precise"
    case reduced = "Reduced"

    mutating func toggle() {
        self = (self == .precise) ? .reduced : .precise
    }
}

private struct LocationPillView: View {
    let location: String
    let type: LocationType
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(location)
                    .font(.headline)
                Button(action: onToggle) {
                    Text(type.rawValue)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Material.ultraThin)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Material.ultraThin)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.25), radius: 10, y: 8)
    }
}

private struct ProgressStepsView: View {
    let steps: [String]
    let currentIndex: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("Processing capture…")
                .font(.headline)
                .foregroundStyle(.white)
            HStack(spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    let isCompleted = index < currentIndex
                    let isActive = index == currentIndex
                    let fillStyle: AnyShapeStyle = isCompleted
                        ? AnyShapeStyle(DesignTokens.ColorPalette.primary)
                        : (isActive ? AnyShapeStyle(Material.ultraThin) : AnyShapeStyle(Color.white.opacity(0.2)))

                    VStack(spacing: 6) {
                        Circle()
                            .fill(fillStyle)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.footnote.bold())
                                    .foregroundStyle(isCompleted || isActive ? .black : .white.opacity(0.7))
                            )
                            .frame(width: 32, height: 32)
                        Text(step)
                            .font(.caption2.bold())
                            .foregroundStyle(isCompleted || isActive ? .white : .white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 24)
    }
}

private struct CameraControlsView: View {
    let onCapture: () -> Void
    let onGallery: () -> Void
    let onChat: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 36) {
            Button(action: onGallery) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(Material.ultraThin)
                    .clipShape(Circle())
            }

            Button(action: onCapture) {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 6)
                    .frame(width: 92, height: 92)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 70, height: 70)
                    )
            }

            Button(action: onChat) {
                Image(systemName: "ellipsis.message")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(Material.ultraThin)
                    .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SlideOutDrawerView: View {
    let isOpen: Bool
    let onToggle: () -> Void
    private let drawerWidth: CGFloat = 300

    var body: some View {
        ZStack(alignment: .trailing) {
            if isOpen {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture(perform: onToggle)
                    .transition(.opacity)
            }

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Menu")
                        .font(.title2.bold())
                    Spacer()
                    Button(action: onToggle) {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    DrawerRow(icon: "map", title: "Map", subtitle: "Explore nearby points")
                    DrawerRow(icon: "list.bullet.rectangle", title: "Library", subtitle: "Past narrations & downloads")
                    DrawerRow(icon: "gearshape", title: "Settings", subtitle: "Language, privacy, offline")
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Storage")
                        .font(.headline)
                    ProgressView(value: 0.45)
                    Text("225 MB of 500 MB used")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .frame(width: drawerWidth)
            .frame(maxHeight: .infinity)
            .background(Material.ultraThin)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(radius: 20)
            .padding(.vertical, 40)
            .offset(x: isOpen ? 0 : drawerWidth + 60)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isOpen)
        }
    }

    private struct DrawerRow: View {
        let icon: String
        let title: String
        let subtitle: String

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .frame(width: 36, height: 36)
                    .background(Material.ultraThin)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
