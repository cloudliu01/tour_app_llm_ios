# Quickstart — Conversation-First Travel Narration

## 1. Environment Setup
1. Install Xcode 16 or newer with iOS 18.1 SDK.
2. Clone the repository and open the workspace via `xed .`.
3. Ensure Sign in with Apple and WeChat test accounts are configured (sandbox).

## 2. Simulator Configuration
1. Boot two simulators: iPhone 8 and iPhone 15 Pro (iOS 18.1).
2. For geofence testing, load GPX routes matching planned POIs.
3. Attach simulated headphones (Developer Menu → Audio Output) before auto-play tests.

## 3. Running the App
1. Build with `xcodebuild -scheme TourAppLLM -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build`.
2. Run on each simulator, grant camera, microphone, location (Precise), and notification permissions when prompted.
3. Verify chat overlay appears after first capture and auto-plays sequential bubbles.

## 4. Feature Validation Checklist
- Capture photo → narration starts within KPI targets (3 s cached, 8 s new).
- Geofence arrival triggers notification; enabling auto-play with headphones starts playback without extra taps.
- Personalization commands ("更活泼", "英文版") append new bubble sets.
- Offline mode: toggle Airplane mode and confirm cached threads remain playable.
- Battery sampling: run 30-minute walking simulation and confirm MetricKit logs <5% battery impact.

## 5. Observability & Analytics
- Confirm events for capture, matching, generation, playback, feedback, cache sync, auto-play attempts appear in analytics console.
- Record request IDs for each session to aid debugging.

## 6. Next Steps
- Review `research.md`, `data-model.md`, and `contracts/openapi.yaml` before implementation planning.
- Run `.specify/scripts/bash/update-agent-context.sh codex` after incorporating new technical learnings.
