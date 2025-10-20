# Tasks — Conversation-First Travel Narration

## Overview
- Feature: Conversation-First Travel Narration
- Plan Reference: /Users/liulizhuang/GitHubProjects/tour_app_llm_ios/.specify/features/20251020-define-chat-guide/plan.md
- Spec Reference: /Users/liulizhuang/GitHubProjects/tour_app_llm_ios/.specify/features/20251020-define-chat-guide/spec.md
- Generated: 2025-10-20

## Dependencies
- Story Order: [US1] → [US2] → [US3]
- Parallel Opportunities: T005 ↔ T006, T007 ↔ T008, T011 ↔ T012, T014 ↔ T017

## Implementation Strategy
- MVP Scope: Deliver [US1] Photo-guided narration capture-to-chat loop.
- Iterative Steps: Ship US1 baseline capture flow, layer geofence auto-play (US2), then add personalization, offline reuse, and feedback (US3), concluding with polish tasks.

## Phase 1 — Setup
- [X] T001 Configure SwiftUI workspace structure in TourAppLLM.xcodeproj/project.pbxproj per module layout
- [X] T002 Add required dependencies (MetricKit, Crashlytics, WeChat SDK stubs) in TourAppLLM.xcodeproj/project.pbxproj
- [X] T003 Establish design token definitions in TourAppLLM/Resources/DesignTokens.swift

## Phase 2 — Foundational
- [X] T004 Implement permission preference store and onboarding hooks in TourAppLLM/Shared/Services/PermissionStore.swift
- [X] T005 [P] Implement LRU cache manager aligned to 500 MB budget in TourAppLLM/Shared/Cache/NarrationCacheManager.swift
- [X] T006 [P] Scaffold narration API client with request/response models in TourAppLLM/Shared/Networking/NarrationAPI.swift
- [X] T007 Seed analytics event dispatcher with required schemas in TourAppLLM/Shared/Analytics/NarrationAnalytics.swift

## Phase 3 — User Story US1 (P1)
- Story Goal: Enable travelers to capture a photo and immediately receive segmented narration within the chat overlay.
- Independent Test Criteria: Photo capture produces a thread whose first audio segment plays within KPI bounds (≤3 s cached, ≤8 s generated) and bubble highlighting advances sequentially.
- Implementation Tasks:
  - [ ] T008 [US1] Build camera capture view with shutter, gallery, and location pill in TourAppLLM/Features/Camera/CameraCaptureView.swift
  - [ ] T009 [P] [US1] Implement photo capture pipeline and upload service in TourAppLLM/Features/Camera/CameraCaptureService.swift
  - [ ] T010 [US1] Render chat overlay with segmented bubbles and playback controls in TourAppLLM/Features/Chat/ChatOverlayView.swift
  - [ ] T011 [P] [US1] Handle narration streaming and bubble activation in TourAppLLM/Shared/Networking/NarrationStreamHandler.swift

## Phase 4 — User Story US2 (P1)
- Story Goal: Trigger narrations automatically when a traveler enters a geofenced point of interest and manage notification consent.
- Independent Test Criteria: Geofence arrival with headphones delivers notification (or auto-plays when opted in) and opens the matching thread from the first segment.
- Implementation Tasks:
  - [ ] T012 [US2] Implement geofence scheduling and debounce logic in TourAppLLM/Features/Location/GeofenceScheduler.swift
  - [ ] T013 [P] [US2] Create onboarding push-permission and headphone opt-in flow in TourAppLLM/Features/Onboarding/NotificationConsentFlow.swift
  - [ ] T014 [US2] Extend chat auto-play controller to respect consent and headphone state in TourAppLLM/Features/Chat/AutoPlayController.swift

## Phase 5 — User Story US3 (P2)
- Story Goal: Allow travelers to personalize narration tone/language, reuse cached content offline, and submit usefulness feedback.
- Independent Test Criteria: Users can issue regeneration commands, replay cached threads without network, and log feedback per segment with analytics confirmation.
- Implementation Tasks:
  - [ ] T015 [US3] Add natural-language command composer to chat input in TourAppLLM/Features/Chat/CommandComposer.swift
  - [ ] T016 [P] [US3] Integrate regeneration endpoint and thread append logic in TourAppLLM/Shared/Networking/NarrationAPI.swift
  - [ ] T017 [US3] Persist offline thread history and replay state in TourAppLLM/Features/Chat/ThreadHistoryStore.swift
  - [ ] T018 [P] [US3] Capture usefulness feedback events and forward to analytics in TourAppLLM/Shared/Analytics/NarrationAnalytics.swift

## Final Phase — Polish & Cross-Cutting
- [ ] T019 Validate KPI instrumentation and export checklist in TourAppLLM/Shared/Analytics/NarrationAnalytics.swift
- [ ] T020 Document simulator validation steps and edge cases in .specify/features/20251020-define-chat-guide/quickstart.md
- [ ] T021 Run battery impact review and record findings in PRD/performance-notes.md

## Parallel Execution Examples
- US1: T009 (capture pipeline) can proceed in parallel with T011 (stream handling) once base networking scaffolds exist.
- US2: T012 (geofence scheduler) and T013 (notification consent flow) run concurrently; both feed into T014.
- US3: T016 (regeneration integration) and T018 (feedback analytics) progress in parallel after API scaffolding.

## Validation Summary
- All tasks adhere to checklist format with IDs, optional [P], and explicit file paths.
- Each user story phase includes independent test criteria ensuring testable increments.
- MVP recommendation: Complete Phase 1–3 to deliver photo-triggered narration before expanding to geofencing and personalization.
