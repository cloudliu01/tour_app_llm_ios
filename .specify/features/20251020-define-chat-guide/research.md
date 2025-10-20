# Research Summary — Conversation-First Travel Narration

## Decision 1: Offline POI Seeding Strategy
- **Decision**: Preload and maintain a lightweight offline catalog of the top 20 points of interest within a 10 km radius of the user’s last-known city, refreshed on Wi‑Fi and capped at 50 MB of metadata/audio previews.
- **Rationale**: Keeps cache within the 500 MB budget, focuses on likely visits, and aligns with Principle 3 by maximizing cache hits without shipping large global bundles.
- **Alternatives Considered**:
  - Ship a global static POI pack (rejected due to storage and localization overhead).
  - Require manual downloads per city (rejected for violating “零学习成本” experience).

## Decision 2: Launch Languages & Voices Scope
- **Decision**: Launch with CN, EN, and JP narrations each offering one default premium-quality TTS voice, plus an alternate voice for CN to cover masculine/feminine tone preferences; expose voice toggle in settings.
- **Rationale**: Meets Principle 1 localization goals, keeps generation pipeline manageable, and honors personalization without overwhelming UI at v1.
- **Alternatives Considered**:
  - Offer multiple voices per language at launch (rejected due to increased QA footprint and TTS cost).
  - Launch CN-only then add EN/JP post-MVP (rejected because spec positions tri-language support as core value).

## Decision 3: Push Notification Opt-in Strategy
- **Decision**: Introduce push permission during onboarding with value-copy tied to “到点自动播” and default to notification-only (no auto-play) until opt-in confirmed and headphones detected; allow in-app reminders if the user declines.
- **Rationale**: Satisfies Principle 2 transparency, gives users control, and still enables Principle 3 requirements once consent is granted.
- **Alternatives Considered**:
  - Request push permission at first geofence event (risking surprise and lower opt-in rates).
  - Force auto-play without push permission (violates privacy expectations and iOS policy).
