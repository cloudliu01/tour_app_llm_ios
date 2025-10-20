# Conversation-First Travel Narration

## Summary
- **Feature Overview**: Deliver an iOS travel companion where users capture a photo or arrive at a point of interest and immediately receive segmented, conversational audio narration in a chat overlay.
- **Primary Users**: Independent travelers, family tourists, cultural explorers, and business travelers visiting unfamiliar locations.
- **Business Value**: Strengthens differentiation through a “conversation-as-tour-guide” experience, enabling premium engagement, retention, and data-driven insights on travel patterns.

## Goals
- Validate the end-to-end capture → narration → playback loop on iPhone 8 and later running iOS 18.1+.
- Ensure the chat overlay becomes the single surface for narration discovery, control, personalization, and history.
- Guarantee resilient access to narrations across weak connectivity via reuse, caching, and offline playback.

## User Stories & Priorities
- **P1 — US1 Photo-Guided Narration**: As a traveler capturing a landmark photo, I receive immediate segmented narration in the chat overlay with sequential playback and bubble highlighting.
- **P1 — US2 Location-Triggered Narration**: As a traveler approaching a point of interest with headphones connected, I am prompted (or auto-played on opt-in) with the relevant chat thread starting from the first segment.
- **P2 — US3 Personalized & Reusable Narrations**: As a traveler, I can issue natural-language commands (e.g., “更活泼”, “英文版”) to regenerate narration blocks, replay cached content offline, and provide usefulness feedback per segment.

## Non-Goals
- Supporting non-iOS platforms, desktop clients, or community-generated content.
- Introducing social sharing, public comments, or merchandising flows.
- Delivering granular itinerary planning beyond the narrated points of interest.

## User Scenarios & Testing
- **Scenario A (Photo trigger)**: User takes a photo of a landmark → system identifies or generates narration → chat overlay opens, auto-plays the first segment, and highlights each bubble as playback proceeds.
- **Scenario B (Location trigger)**: User enters a defined geofence for a point of interest with headphones connected and auto-play enabled → notification (or auto playback if allowed) opens the relevant chat thread and begins sequential narration.
- **Edge & Recovery (Weak network)**: User travels through spotty coverage → system falls back to cached narrations or text-first delivery → user sees retry states and can replay once audio arrives.

## Functional Requirements
1. **FR1 Conversation Surface**: The chat overlay must present every narration as segmented text bubbles with synchronized audio; tapping any bubble restarts audio from that segment and continues sequential playback.
2. **FR2 Trigger Handling**: The product must launch the chat overlay from both photo capture and location arrival events, automatically starting narration from the first segment while highlighting current progress.
3. **FR3 Personalization Commands**: Users must be able to issue natural-language commands (e.g., “更活泼”, “英文版”) within the chat input to request regenerated narrations; regenerated blocks must append to the thread without removing earlier content.
5. **FR5 Offline & Caching**: The system must reuse cached narrations when available, cap local storage at 500 MB using least-recently-used removal, and allow offline playback of previously downloaded segments.
6. **FR6 Notifications & Auto-Play**: Upon geofence entry, the system must send a notification prompt by default; if the user has enabled auto-play with headphones connected, playback must begin automatically without additional taps.
7. **FR7 Consent & Privacy**: First-run flows must request camera, microphone, and location permissions with context-aligned copy and provide settings toggles to disable data retention for service improvement.
8. **FR8 Analytics Coverage**: Capture all key events across capture, matching, generation, playback, feedback, cache usage, auto-play attempts, and errors as defined in “Overview vNext”, with metadata necessary for KPI reporting.

## Success Criteria
- 95% of narrated sessions deliver the first audio frame within 3 s when hitting cache and within 8 s for newly generated content during beta testing.
- 90% of eligible geofence arrivals result in a delivered notification, and 98% of opted-in auto-play sessions start without manual intervention.
- User satisfaction (“有用” feedback) reaches at least 70% across pilot cohorts, and day-two retention improves by 20% over baseline camera-only prototypes.
- Daily battery impact for active users remains below 5%, verified through instrumentation over a 7-day field test.

## Key Entities
- **Narration Thread**: A conversational timeline tied to a photo or location visit, containing ordered narration blocks, user commands, metadata (timestamp, location, language), and playback status.
- **Narration Segment**: A single text bubble with associated audio clip, highlighting state, and readiness flags (text-ready, audio-ready); maintains the next segment pointer for sequential playback.
- **Trigger Event**: Context describing how the thread started (photo capture details, geofence identifier, device state such as headphones); powers analytics and personalization logic.
- **Cache Item**: Stored narration package referencing thread ID, language, voice, and style fingerprint to support reuse, eviction priority, and offline access eligibility.

## Assumptions
- Point-of-interest catalog and vector search results are sufficiently accurate to supply top-k candidates within the stated latency goals.
- Users have intermittent connectivity; when offline, previously cached narrations remain accessible until the cap is reached.
- Sign-in with Apple and WeChat accounts are configured outside this feature scope but available for authentication flows referenced here.

## Dependencies
- High-quality location services, including geofencing APIs, to detect arrivals with the required precision.
- External narration generation pipeline (text plus TTS) capable of streaming segments in order.
- Push notification infrastructure and entitlement approvals to deliver “讲解已准备就绪” alerts.
- Analytics warehouse definitions to capture KPI metrics (hit rate, offline usage, feedback, retention).

## Risks & Mitigations
- **Risk**: Weak network conditions cause narration delays exceeding expectations — **Mitigation**: Provide text-first fallback, clear retry prompts, and proactive caching of popular locations.
- **Risk**: Excessive geofence events drain battery or create false positives — **Mitigation**: Use conservative visit detection, debounce triggers, and enforce minimum intervals between autoplay prompts.
- **Risk**: Users overwhelmed by relentless playback in public spaces — **Mitigation**: Default to notifications, require headphone connection for auto-play, and expose easy toggles in settings.
