## Repository Guidelines

### Project Structure & Module Organization
The repository currently centers on the product and IA brief in `README.md`; keep that document synced with feature decisions before shipping code. When the SwiftUI app lands, create `TourAppLLM.xcodeproj` (or `.xcworkspace`) at the root and group source under `TourAppLLM/` with feature folders such as `Camera`, `Playback`, `Map`, `Library`, and `Settings` to mirror the IA. Place shared models and services in `Shared/` (e.g., `MediaUploadService.swift`, `CacheStore.swift`), and keep assets and localized strings inside `Resources/Assets.xcassets` and `Resources/Strings/`. Store design prompts or diagrams under `Docs/Figma/`. Tests live in `TourAppLLMTests/`, with UI tests in `TourAppLLMUITests/`.

### Build, Test, and Development Commands
Open the project with `xed .` to launch Xcode. Use `xcodebuild -scheme TourAppLLM -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build` for repeatable CI builds. Run the test suite locally with `xcodebuild test -scheme TourAppLLM -destination 'platform=iOS Simulator,name=iPhone 15 Pro'`. When iterating, boot the simulator ahead of time via `xcrun simctl boot "iPhone 15 Pro"` to avoid launch delays.

### Coding Style & Naming Conventions
Follow Swift API Design Guidelines: types in UpperCamelCase, methods and properties in lowerCamelCase. Keep a single view or service per file and append suffixes like `View`, `ViewModel`, `Service`, or `Coordinator` to flag intent. Use 4-space indentation, wrap lines around 120 characters, and rely on Swift concurrency (`async/await`) for network and background work; mark UI updates with `@MainActor`. Adopt `swift-format` once configuration lands; until then, use Xcode’s “Re-Indent” and avoid committing trailing whitespace.

### Testing Guidelines
Write XCTest cases using the `given_when_then` narrative inside each method. Name tests as `test_<Component>_<Condition>_<Expectation>()`, e.g., `test_PlaybackView_showsWaveformSkeleton_whenAudioPending`. Target coverage on the capture pipeline, streaming playback, cache management, retry logic, and telemetry events. Stub network calls with `URLProtocol` or dependency-injected clients so tests can run offline.

### Commit & Pull Request Guidelines
History so far favors concise, Title Case commit subjects (`Update README.md`). Keep that tone but move to imperative verbs when changing code, e.g., `Add CameraCaptureView`. Each pull request should include: a short context summary referencing the related product decision, screenshots or screen recordings for UI changes, simulator/device targets tested, and links to issues or Figma prompts. Flag new background tasks, permissions, or analytics events so reviewers can verify entitlements and data handling.
