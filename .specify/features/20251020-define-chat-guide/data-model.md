# Data Model — Conversation-First Travel Narration

## Entity: NarrationThread
- **Description**: Represents a single storytelling session initiated by photo capture or location arrival.
- **Identifiers**: `thread_id` (UUID), `origin_type` (photo|geofence), `origin_ref` (photo_id or geofence_id).
- **Core Fields**:
  - `user_id` (nullable for guest) — hashed identifier.
  - `start_timestamp`
  - `location_snapshot` (lat, lon, place_name, accuracy)
  - `language` (CN|EN|JP)
  - `voice_profile` (default|alt_cn|alt_en|alt_jp)
  - `auto_play_enabled` (boolean)
  - `status` (pending|playing|completed|error)
  - `cache_origin` (fresh_generate|cache_hit)
  - `metadata` (key-value for analytics ids, eg `request_id`, `idempotency_key`).
- **Relationships**: 1:N with `NarrationSegment`; 1:1 optional with `TriggerEvent`; 1:N with `UserCommand` (regenerations, feedback).
- **Validation Rules**:
  - `language` must align with enabled locales per settings.
  - `status` transitions only forward except to `error` (see transitions).
- **State Transitions**:
  - `pending` → `playing` when first segment ready.
  - `playing` → `completed` after final segment playback.
  - Any state → `error` if generation/TTS fails (thread retains retry pointer).

## Entity: NarrationSegment
- **Description**: A discrete bubble of narration text with synchronized audio.
- **Identifiers**: `segment_id` (UUID), `thread_id` (FK), `sequence_index` (int).
- **Core Fields**:
  - `text` (rich text payload with language markers)
  - `audio_url` (local or remote reference)
  - `duration_ms`
  - `is_stream_ready` (boolean for text available)
  - `is_audio_ready` (boolean for audio cached)
  - `highlight_state` (inactive|active|completed)
  - `play_count`
  - `created_at`, `updated_at`
- **Relationships**: Belongs to `NarrationThread`; optional link to `CacheItem` when stored offline.
- **Validation Rules**:
  - `sequence_index` must be contiguous starting at 0 within a thread.
  - `audio_url` required before shifting to `highlight_state=active`.
  - `duration_ms` ≤ 120000 (2 minutes) to keep segments focused.
- **State Transitions**:
  - `highlight_state` follows inactive → active → completed; returning to active allowed when replayed.

## Entity: TriggerEvent
- **Description**: Captures the context that created or reopened a thread.
- **Identifiers**: `event_id` (UUID), `thread_id` (FK).
- **Core Fields**:
  - `event_type` (photo_capture|geofence_entry|regeneration)
  - `device_state` (headphones_status, network_quality)
  - `capture_artifacts` (photo metadata, vector match confidence)
  - `geofence_radius`
  - `auto_play_requested` (boolean)
  - `timestamp`
- **Relationships**: Belongs to `NarrationThread`.
- **Validation Rules**:
  - `geofence_radius` required for geofence events.
  - `capture_artifacts.photo_id` required for photo events.

## Entity: CacheItem
- **Description**: Represents a locally stored narration package or segment.
- **Identifiers**: `cache_key` (hash of image|lang|voice|style), `thread_id` (FK optional if packaged by thread).
- **Core Fields**:
  - `scope` (thread|segment)
  - `size_bytes`
  - `last_accessed`
  - `expires_at` (optional manual eviction signal)
  - `storage_path`
  - `reuse_count`
- **Relationships**: Links to `NarrationSegment` entries via `segment_id` reference list.
- **Validation Rules**:
  - Enforce global cache sum ≤ 500 MB; items beyond limit evicted by LRU.
  - `storage_path` must reference sandboxed directory per iOS guidelines.

## Entity: PermissionPreference
- **Description**: Stores user consent choices for camera, microphone, location, and notifications.
- **Identifiers**: `preference_id` (UUID), `user_id` (nullable).
- **Core Fields**:
  - `camera_authorized` (boolean)
  - `microphone_authorized` (boolean)
  - `location_accuracy` (precise|reduced|denied)
  - `notifications_enabled` (boolean)
  - `auto_play_opt_in` (boolean)
  - `service_improvement_opt_in` (boolean)
  - `last_updated`
- **Relationships**: Referenced by Settings module and gating logic for auto-play.
- **Validation Rules**:
  - `auto_play_opt_in` can only be true if `notifications_enabled` and `headphones_detected` at opt-in moment.
  - Default `service_improvement_opt_in` true, but must be reversible instantly.

## Entity: UserCommand
- **Description**: Represents user-issued instructions like tone adjustments or feedback within a thread.
- **Identifiers**: `command_id` (UUID), `thread_id` (FK).
- **Core Fields**:
  - `command_type` (regenerate|feedback|settings_change)
  - `payload` (e.g., "更活泼", "👍", speed adjustments)
  - `timestamp`
  - `result_thread_id` (FK if regeneration spawned new segments)
- **Relationships**: Many-to-one with `NarrationThread`; regeneration commands link to derived threads or segments.
- **Validation Rules**:
  - `result_thread_id` required when `command_type=regenerate` to trace appended block.
  - Feedback commands must map to `segment_id` when referencing usefulness per bubble.
