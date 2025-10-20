<!--
Sync Impact Report
Version: 1.0.0 → 1.1.0
Modified Principles: Principle 1 — Native Apple Experience → Principle 1 — Conversation-First Native Foundation; Principle 3 — Offline Resilience & Performance (expanded KPI guardrails); Principle 4 — Observable & Inclusive Delivery (clarified instrumentation scope)
Added Sections: none
Removed Sections: none
Templates Requiring Updates: ⚠ .specify/templates/plan-template.md (missing); ⚠ .specify/templates/spec-template.md (missing); ⚠ .specify/templates/tasks-template.md (missing); ⚠ .specify/templates/commands (directory missing)
Follow-up TODOs: Establish maintainer roster; Create missing .specify templates aligned with principles; Propagate conversation-first chat decisions into downstream specs once templates exist
-->

# Tour App LLM iOS Constitution

## Metadata
- Constitution Version: 1.1.0
- Ratification Date: 2025-10-20
- Last Amended Date: 2025-10-20
- Maintainers: TODO(OWNERS) nominate core maintainers for constitutional decisions

## Preamble
Tour App LLM iOS delivers on-device capture, narration playback, and contextual travel guidance inspired by the product brief in `README.md` and the consolidated “Overview vNext”. This constitution codifies the non-negotiable standards for delivering a Swift-based iOS experience that honors Apple's design system, safeguards user trust, and keeps the roadmap aligned with the capture-to-chat-to-playback journey.

## Principle 1 — Conversation-First Native Foundation
- MUST implement the app in Swift and SwiftUI, align layouts with Human Interface Guidelines for iPhone 8 and newer screens, and validate Dynamic Type and accessibility traits on both notch and non-notch simulators (baseline: iPhone 8, iPhone 15 Pro running iOS 18.1+).
- MUST present the Chat Overlay as the primary interaction layer: camera home launches the conversational thread, narration flows bubble-by-bubble in order, clicking a bubble restarts that segment, and no separate transport controls may be introduced outside the bubble interactions for this release.
- MUST keep design tokens (color #0A84FF palette, typography, corner radii, glassmorphism) in sync with `README.md`, “Overview vNext”, and any assets under `Docs/Figma/`.
Rationale: A conversation-first experience that feels Apple-native ensures the “对话即导游” promise remains coherent across devices.

## Principle 2 — Responsible Data & Privacy
- MUST request camera, microphone, and location permissions with just-in-time copy that mirrors onboarding promises and avoid collecting unnecessary metadata.
- MUST store media, transcripts, and analytics tokens with user consent, honoring the default privacy toggles and providing clear opt-outs for service-improvement data.
- MUST isolate authentication flows for Sign in with Apple and WeChat, persisting only scoped identifiers required for downstream services.
Rationale: Users grant sensitive access; transparent data boundaries preserve trust and regulatory compliance.

## Principle 3 — Offline Resilience & Performance
- MUST keep capture, upload, generation, and TTS pipelines resilient with retry, caching, and background task policies defined in the README and “Overview vNext” (e.g., 500 MB LRU cache, text-first fallback, sequential playback resume).
- MUST meet the declared KPIs: cache hit first frame ≤3 s, new narration ≤8 s, capture-to-audio ≤10 s, geo-trigger P95 ≤2.5 s, playback resume <300 ms, daily battery impact ≤5%, and document remediation plans if any target is temporarily waived.
- MUST ship automated coverage for cache management, background completion notifications, weak-network guardrails, and bubble-sequencing logic before enabling related features.
Rationale: Travelers depend on responsive guidance in poor connectivity; resilient workloads prevent regressions.

## Principle 4 — Observable & Inclusive Delivery
- MUST instrument key events (capture, generation, playback sequence, feedback, cache, auto-play triggers) following the analytics matrix in the README/“Overview vNext” and keep schema changes documented.
- MUST include accessibility validation, localized copy (CN/EN/JP), and audio preference toggles in definition of done for relevant tasks.
- MUST require code reviews that verify adherence to architecture module boundaries (Camera, Chat Overlay, Map, Settings, Shared services) and link to the governing briefs.
Rationale: Observability and inclusive defaults enable confident releases and global usability.

## Governance
- Amendment Procedure: Maintainers propose amendments via pull request referencing this file; approval requires two maintainer reviews or, if maintainers are unassigned, consensus from project leads documented in the PR thread.
- Versioning Policy: Update the Constitution Version according to semantic versioning (MAJOR for breaking principle changes, MINOR for new or expanded principles, PATCH for clarifications). All amendments must update `Last Amended Date`.
- Compliance Reviews: Conduct a constitution compliance review at the start of each release cycle and before major feature launches; document exceptions and remediation plans in the relevant PR or release notes.
