# Implementation Plan — Conversation-First Travel Narration

## Technical Context
- Platform: iOS 18.1+ SwiftUI app targeting iPhone 8 and newer devices, leveraging camera, location, audio playback, notifications, and BackgroundTasks.
- Core Modules: Camera capture pipeline, Chat Overlay conversation surface, Map drawer, Settings/privacy controls, Shared services for upload, narration orchestration, caching, analytics.
- Integrations: Sign in with Apple, WeChat authentication, vector search & narration generation (GPT + TTS), MinIO/cloud storage, PostgreSQL with PostGIS & PGVector, push notifications, MetricKit/Crashlytics.
- Data Touchpoints: Local SQLite/CoreData index with 500 MB LRU cache, remote storage for media and narrations, telemetry events (capture, match, generation, playback, feedback, auto-play), privacy toggles.
- Known Decisions: Offline catalog prefetch top 20 POIs within 10 km refreshed on Wi‑Fi; launch CN/EN/JP with single premium voice each plus CN alternate; push permission requested during onboarding with headphone-gated auto-play.

## Constitution Check (Pre-Design)
- Principle 1 Alignment: Camera home + chat overlay sequencing maintained; no external playback UI; plan includes validation on iPhone 8 and iPhone 15 Pro simulators.
- Principle 2 Alignment: Permissions and privacy toggles scoped; must confirm notification prompt approach to avoid overreach.
- Principle 3 Alignment: KPI targets (3 s/8 s/10 s/2.5 s/<300 ms/<5%) embedded; offline catalog detail pending.
- Principle 4 Alignment: Analytics coverage and localization commitments acknowledged; contracts must enumerate required events.
- Gating Decision: PASS contingent on resolving Phase 0 clarifications.

## Phase 0 — Research Outline
- Unknowns to Resolve: Completed (documented in `research.md`).
- Research Tasks:
  - Offline POI seeding strategy — ✅
  - CN/EN/JP TTS voice availability and prioritization — ✅
  - Geo-trigger notification opt-in best practices — ✅
- Deliverable: `research.md` (2025-10-20)

## Phase 1 — Design & Contracts
- Data Model Tasks: ✅ Documented Narration Thread, Segment, Trigger Event, Cache Item, Permission Preference, and UserCommand in `data-model.md`.
- Contract Tasks: ✅ Authored OpenAPI spec covering capture, geofence, regeneration, feedback, streaming, and cache sync under `contracts/openapi.yaml`.
- Quickstart Tasks: ✅ Added simulator, build, validation, and analytics guidance in `quickstart.md`.
- Agent Context Update: ✅ Ran `.specify/scripts/bash/update-agent-context.sh codex` to sync auto-generated insights.
- Deliverables: `data-model.md`, `contracts/openapi.yaml`, `quickstart.md`, `.specify/memory/agents/codex.md`

## Phase 2 — Planning & Next Steps
- Implementation Strategy: Phase A build capture→chat flow, Phase B add auto-play & offline caching, Phase C localize, refine analytics, finalize battery safeguards.
- Testing & QA Focus: Weak-network performance, geofence debounce, sequential bubble playback accuracy, personalization commands, battery usage sampling against 5% target.
- Risks & Mitigations: Service latency spikes (stage progress indicators, caching), inaccurate POI matches (manual retry + feedback loop), user fatigue with prompts (settings toggles & respectful defaults).
- Hand-off Checklist: Approved research decisions, signed-off data model & contracts, agent context synced, backlog tickets aligned with KPIs and constitution principles.

## Constitution Check (Post-Design)
- Re-evaluated Principles: All four principles satisfied—chat-first flows preserved, privacy decisions documented, KPI commitments reflected in contracts, analytics and localization accounted for.
- Outstanding Issues: None; research decisions incorporated across artifacts.
- Final Recommendation: Ready to proceed to `/speckit.plan` execution on branch `build-define-chat-guide`.
