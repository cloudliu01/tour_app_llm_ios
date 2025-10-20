<!--
Sync Impact Report
Version: none → 1.0.0
Modified Principles: (new document)
Added Sections: Preamble; Principles; Governance
Removed Sections: none
Templates Requiring Updates: ⚠ .specify/templates/plan-template.md (missing); ⚠ .specify/templates/spec-template.md (missing); ⚠ .specify/templates/tasks-template.md (missing); ⚠ .specify/templates/commands (directory missing)
Follow-up TODOs: Establish maintainer roster; Create missing .specify templates aligned with principles
-->

# Tour App LLM iOS Constitution

## Metadata
- Constitution Version: 1.0.0
- Ratification Date: 2025-10-20
- Last Amended Date: 2025-10-20
- Maintainers: TODO(OWNERS) nominate core maintainers for constitutional decisions

## Preamble
Tour App LLM iOS delivers on-device capture, narration playback, and contextual travel guidance inspired by the product brief in `README.md`. This constitution codifies the non-negotiable standards for delivering a Swift-based iOS experience that honors Apple's design system, safeguards user trust, and keeps the roadmap aligned with the core capture-to-playback journey.

## Principle 1 — Native Apple Experience
- MUST implement the app in Swift and SwiftUI, aligning layouts with Human Interface Guidelines for iPhone 8 and newer screens while supporting Dynamic Type and accessibility traits.
- MUST target iOS 18.1+ deployments and validate core flows (camera, playback, map, history, settings) on both notch and non-notch devices (iPhone 8, iPhone 15 Pro simulator baselines).
- MUST keep design tokens (color, typography, corner radii) in sync with the design system captured in `README.md` and any `Docs/Figma` assets.
Rationale: A consistent Apple-native experience strengthens usability and accelerates App Store approval.

## Principle 2 — Responsible Data & Privacy
- MUST request camera, microphone, and location permissions with just-in-time copy that mirrors onboarding promises and avoid collecting unnecessary metadata.
- MUST store media, transcripts, and analytics tokens with user consent, honoring the default privacy toggles and providing clear opt-outs for service-improvement data.
- MUST isolate authentication flows for Sign in with Apple and WeChat, persisting only scoped identifiers required for downstream services.
Rationale: Users grant sensitive access; transparent data boundaries preserve trust and regulatory compliance.

## Principle 3 — Offline Resilience & Performance
- MUST keep capture, upload, generation, and TTS pipelines resilient with retry, caching, and background task policies defined in the README (e.g., 500 MB cap, segmented progress feedback).
- MUST deliver first-frame playback within the stated targets (<3 s cache hit, <8 s new narration) and surface fallbacks (text draft, retry prompts) when deadlines are missed.
- MUST ship automated coverage for cache management, background completion notifications, and weak-network guardrails before enabling related features.
Rationale: Travelers depend on responsive guidance in poor connectivity; resilient workloads prevent regressions.

## Principle 4 — Observable & Inclusive Delivery
- MUST instrument key events (capture, generation, playback, feedback, cache) following the analytics matrix in the README and keep schema changes documented.
- MUST include accessibility validation, localized copy (CN/EN/JP), and audio preference toggles in definition of done for relevant tasks.
- MUST require code reviews that verify adherence to architecture module boundaries (Camera, Playback, Map, Library, Settings, Shared services) and link to the governing briefs.
Rationale: Observability and inclusive defaults enable confident releases and global usability.

## Governance
- Amendment Procedure: Maintainers propose amendments via pull request referencing this file; approval requires two maintainer reviews or, if maintainers are unassigned, consensus from project leads documented in the PR thread.
- Versioning Policy: Update the Constitution Version according to semantic versioning (MAJOR for breaking principle changes, MINOR for new or expanded principles, PATCH for clarifications). All amendments must update `Last Amended Date`.
- Compliance Reviews: Conduct a constitution compliance review at the start of each release cycle and before major feature launches; document exceptions and remediation plans in the relevant PR or release notes.
