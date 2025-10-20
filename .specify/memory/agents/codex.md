# Agent Context — Codex

<!-- AUTO-GENERATED CONTEXT START -->
- Preload and maintain a lightweight offline catalog of the top 20 points of interest within a 10 km radius of the user’s last-known city, refreshed on Wi‑Fi and capped at 50 MB of metadata/audio previews.
- Launch with CN, EN, and JP narrations each offering one default premium-quality TTS voice, plus an alternate voice for CN to cover masculine/feminine tone preferences; expose voice toggle in settings.
- Introduce push permission during onboarding with value-copy tied to “到点自动播” and default to notification-only (no auto-play) until opt-in confirmed and headphones detected; allow in-app reminders if the user declines.
- 95% of narrated sessions deliver the first audio frame within 3 s when hitting cache and within 8 s for newly generated content during beta testing.
- 90% of eligible geofence arrivals result in a delivered notification, and 98% of opted-in auto-play sessions start without manual intervention.
- User satisfaction (“有用” feedback) reaches at least 70% across pilot cohorts, and day-two retention improves by 20% over baseline camera-only prototypes.
- Daily battery impact for active users remains below 5%, verified through instrumentation over a 7-day field test.
- Known Decision: Offline catalog prefetch top 20 POIs within 10 km refreshed on Wi‑Fi
- Known Decision: launch CN/EN/JP with single premium voice each plus CN alternate
- Known Decision: push permission requested during onboarding with headphone-gated auto-play.
<!-- AUTO-GENERATED CONTEXT END -->

<!-- MANUAL NOTES START -->
No manual notes recorded yet.
<!-- MANUAL NOTES END -->

