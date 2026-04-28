# Completed

## 2026-04-29 (screen and visual context awareness)

- `CM-BLG-113` Screen and visual context awareness: `ScreenContextService` captures the primary display via `CGDisplayCreateImage` and extracts visible text on-device using `Vision.VNRecognizeTextRequest` (accurate level, automatic language detection). Text is held in memory only — never written to disk independently. `AppState` gains `screenContextEnabled` (backward-compat, default false). `AppModel` exposes `screenContextEnabled` (@Published, persisted), `screenContextText`, `screenContextCapturedAt`, `screenPermissionGranted`, plus `checkScreenPermission()`, `requestScreenPermission()`, and `refreshScreenContext()`. `ConversationRequest` gains a `screenContext: String` field; OpenAI and Ollama prompts inject a "Visible on screen" section (capped at 1500 chars) when non-empty. The local heuristic engine receives the field but ignores it by design. Settings gains a "Screen Context" card: toggle, permission status + grant-access button, refresh-now button with relative timestamp, captured-text preview (first 300 chars), and an on-device privacy note. Live diagnostics section shows screen capture char count when enabled. 7 new tests, 67 total passing.

## 2026-04-29 (multilingual meeting support)

- `CM-BLG-111` Multilingual meeting support: `MeetingLanguage` enum (10 values: auto-detect + 9 languages) with `appleSpeechLocale` and `whisperCode` per case. `MeetingConfiguration` gains `meetingLanguage: String` (persisted, backward-compat default "en"). `SpeechTranscriptionService` gains `setLocale(_:)` to swap the `SFSpeechRecognizer` locale. `WhisperCppTranscriptionService` gains `setLanguage(_:)` to update the `-l` flag per transcription chunk. `ConversationRequest` gains `meetingLanguage: String`; OpenAI and Ollama prompt builders inject a "Respond in X" line for non-English meetings. `startActiveTranscriptionProvider()` calls `applyMeetingLanguageToTranscriptionServices()` so the locale is always aligned when a session starts. Language picker appears in both the Meeting Context card (start screen) and the Identity card (Settings), both wired to `applyMeetingLanguageToTranscriptionServices` via `.onChange`. 9 new tests, 60 total passing.

## 2026-04-28 (offline-capable mode)

- `CM-BLG-112` Offline-capable mode: `AppState` gains `offlineModeEnabled` with backward-compatible decode defaulting to false. `AppModel` exposes `@Published var offlineModeEnabled` (persisted) and `effectiveGenerationProvider` (returns `.localHeuristic` when offline mode is on, otherwise the user-selected provider). `generateConversationGuidance()` and `selectedBriefGenerationStrategy()` now branch on `effectiveGenerationProvider` instead of `generationProvider` directly, so switching offline mode instantly overrides the active provider without changing the user's preference. Settings gains an "Offline Mode" card with a toggle, a four-row capability breakdown showing what stays available offline, and a contextual info note when active. Top bar gains an orange "Offline" capsule badge when offline mode is enabled. 7 new tests (persistence round-trip, backward-compat decode, override logic), 51 total passing.

## 2026-04-28 (autonomous background help)

- `CM-BLG-110` Autonomous background help: `backgroundTaskLabel` (@Published) is set during `generateBriefForSession` and shown in the top bar as a ProgressView pill. `pendingFollowUpSessions` detects completed sessions (≤30 days old) with action items and no follow-up notes. `markFollowUpDone(for:)` sets `followUpNotes = "Handled"` as completion signal. HistoryWorkspaceView gains a "Needs Attention" card with Open and Mark Done per-row actions. 8 new tests, 47 total passing.

## 2026-04-28 (memory controls and privacy)

- `CM-BLG-093` Memory controls and privacy: `AppState` gains `memoryEnabled` + `excludedFromMemoryIDs` with backward-compatible decode. `AppModel` exposes `memorySources`, `toggleMemoryExclusion(for:)`, and `clearMemoryExclusions()`. `CrossSessionMemoryBuilder.build` and `relevantSessions` both accept an exclusion set. Settings gains a "Memory Controls" card: enable/disable toggle, per-session include/exclude rows with outcome badge and relative date, clear-exclusions button, and live memory note preview. 39 tests passing.

## 2026-04-28 (relationship timeline, backlog cleanup)

- `CM-BLG-002` Public repo cleanup: removed tracked `.DS_Store` (already in `.gitignore`); README and product.html were already aligned in earlier pass.
- `CM-BLG-092` Relationship timeline: `RelationshipTimelineBuilder` groups completed sessions by participant name + company, ranks recurring topics by frequency, surfaces last outcome and all-time outcome breakdown. `SessionHistoryView` gains a "People" tab with `RelationshipRowView` list and `RelationshipDetailView` (contact header, topics, outcome breakdown, per-session drill-down). 9 new tests, 39 total passing.

## 2026-04-28 (session auto-start, overlay enhancements, visual polish)

- `CM-BLG-052` Session auto-start suggestions: `checkAutoStartCondition()` fires when audio is capturing and 2+ other-speaker segments arrive with no active session; `showAutoStartSuggestion` published bool drives a dismissible `autoStartSuggestionCard` in `StartSessionWorkspaceView`; cleared on session start or explicit dismiss.
- `CM-BLG-100` Compact why-this-answer hints: `overlayWhyText` exposes `overlayContent.why`; `overlayWhyHint(_:)` renders a compact lightbulb hint line below Points in `OverlayPanelView`.
- `CM-BLG-101` Confidence scoring visibility: plain text confidence label replaced with a color-coded capsule badge (green/yellow/red) via `confidenceBadge(_:)` in the overlay header. 30 tests passing.
- `CM-BLG-103` Premium calm visual system: full typography, spacing, and color refinement pass — `WorkspaceHeroCard` (neutral system gradient, tracked eyebrow), `SurfaceCard` (padding 18→20, softer border, radius 22→20), `DetailBlock` (uppercase tracked label style, full-width), `CompactMetric` (uppercase label, title3.rounded value), `ActionButton` (rounded font, tinted foreground, radius 14→16), `navPill` (rounded font, per-state foreground), `quickStyleButton` (rounded font, active tint). Build clean, 30 tests passing.

## 2026-04-28

- `CM-BLG-001` Testing foundation: converted tests to XCTest, added `GuidanceGuardrailTests.swift`; `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test` passes with 9 tests.
- `CM-BLG-014` Live reliability guardrails: increased min refresh interval (1.6 s → 2.5 s), added trailing-fragment guard, added 3 s post-answer cooldown in `guidanceStabilityReason`. Build clean.
- `CM-BLG-031` Role-aware speaker labeling: `collaboratorRoleLabel` (Prospect/Client/Interviewer/Teammate/Other) now flows into `ConversationRequest` and into both AI service prompts. Speaker-labeled transcript lines replace raw text blobs.
- `CM-BLG-033` Context window shaping: `ConversationRequest.latestQuestion` pinpoints the exact segment to respond to; `buildPrompt` now separates "Latest statement/question" from "Prior context (recent turns)" and trims retrieval to 2 sources. Build clean, 9 tests passing.
- `CM-BLG-041` Sales call specialization: `modeSpecificTactics` and `intentSpecificGuidance` in `MeetingModePromptHelper` inject deep sales tactics (pilot framing, pricing de-risk, objection reversal, next-step closure) into every AI prompt. Intent flows from `detectIntent` through `ConversationRequest.detectedIntent` to the prompt. 12 tests passing.
- `CM-BLG-042` Demo assistance specialization: demo-specific tactics (workflow-first framing, feature gap pivots, conversational pacing questions) in `modeSpecificTactics`. Complete.
- `CM-BLG-043` Interview support specialization: interview mode now gets STAR-structure coaching, outcome-anchoring instruction, conciseness framing, and gap-handling guidance. Intent-specific proof/objection variants tuned for interview context.
- `CM-BLG-044` Internal meeting support specialization: internal-sync tactics (decision forcing, owner naming, blocker + dependency surfacing, binary alignment questions) in `modeSpecificTactics`. Complete.
- `CM-BLG-061` Contact and account context: added `participantName`, `participantCompany`, `relationshipStage`, `priorContextNote` to `MeetingConfiguration` with backward-compatible decoding. `participantContextLine` helper composes a one-line summary into both AI prompts. `meetingContextCard` UI in `StartSessionWorkspaceView`. 15 tests passing.
- `CM-BLG-062` Meeting goals and success criteria: added `meetingGoal`, `targetOutcome`, `mustCoverPoints` to `MeetingConfiguration`; `meetingGoalsSection` injects them into both AI prompts; `meetingGoalsCard` UI in `StartSessionWorkspaceView`.
- `CM-BLG-082` Outcome tracking: `SessionOutcome` enum (pilot/follow-up/blocked/internal-action/open-risk/unclear); auto-detection from summary signals in `saveSummaryResult`; manual override via `saveSessionOutcome`; outcome badge in session history list and detail header. 19 tests passing.
- `CM-BLG-090` Conversation memory: `CrossSessionMemoryBuilder` selects relevant past sessions by participant name → company → meeting type, builds a multi-line memory note (outcome, open commitments, recurring topics, past objections), injected into both AI prompts via `ConversationRequest.crossSessionMemory`. `recurringMemoryItems` in AppModel delegates to the builder.
- `CM-BLG-091` Personal response style memory: `preferredAnswerStyle` stamped onto `MeetingConfiguration` at session start; `suggestedAnswerStyle` computed from modal style in past sessions; "Apply" hint shown in Settings when suggestion differs from current. 30 tests passing.

## 2026-04-26 (Launch-readiness doc audit)

- Audited README, product.html, and all three testing docs against latest shipped work (personalization, recurring memory, mode polish).
- Fixed: README Settings section, What Cuemate Does Today, and Capabilities Roadmap to include preferred answer style and recurring memory.
- Fixed: product.html feature grid (two new cards) and footer roadmap.
- Fixed: manual-beta-plan.md — preferred answer style prerequisite, per-scenario recurring memory and mode cue checks, two new test sections.
- Fixed: live-meeting-checklist.md — pre-meeting answer style and memory checks, during-meeting mode cue checks, three new red flags.
- No code changes. Build verified clean.

## 2026-04-26 (Beta validation pack + launch hygiene + persistence audit)

- Created `.ai-system/testing/manual-beta-plan.md`: four full meeting scenarios (sales, client review, interview, internal sync) with pre/live/post checks, persistence regression test, and provider parity matrix.
- Created `.ai-system/testing/live-meeting-checklist.md`: real-meeting pre/during/post checklist with red flags to log immediately.
- Created `.ai-system/testing/privacy-checklist.md`: covers local storage boundaries, Keychain key handling, provider isolation, transcription path, transparency UI, sensitive-session test.
- Updated `README.md`: reflects 3-surface product (Start Session / History / Settings), current capabilities including pre-meeting briefs and follow-up artifacts, updated privacy model, and accurate provider options.
- Updated `product.html`: sidebar cards match current surfaces, "Two Clear Flows" replaced with "Three Surfaces" grid (Start Session, Live Q/A/A, History), feature grid includes Pre-meeting Briefs and Privacy Transparency cards, hero stats updated to reflect local-first and full-arc positioning.
- `MeetingSessionRecord` now has an explicit memberwise init and a backward-compatible custom `init(from:)` that safely defaults `followUpNotes`, `guidanceHistory`, `documentIDs`, `brief`, and `followUpArtifact` when missing from old stored JSON — prevents `keyNotFound` crashes on old sessions.
- `MeetingSessionStore.loadSessionsSafely()` added — non-throwing variant for app startup and coordinator paths; returns `[]` on any read/decode error.
- `MeetingSessionStore.saveSessions` now auto-creates the sessions directory on first write (handles first-run edge case).
- `SessionHistoryCoordinator.loadStateOrEmpty()` added — non-throwing convenience for use at app startup; delegates to `loadSessionsSafely`.
- `BriefCoordinator.Input.make(configuration:snapshot:documentIDs:priorSessions:ollamaModel:openAIKey:openAIModel:)` added — auto-selects strategy from available credentials so call sites don't repeat strategy logic.
- Build verified clean, zero warnings.

## 2026-04-25

- Restored a local `.ai-system` coordination surface for Cuemate agents.
- Configured git ignore rules so `.ai-system` remains local-only.

## 2026-04-26 (Phase 2 UI + AI brief layer — SessionHistoryView, PreSessionBriefView, OllamaBriefService)

- SessionHistoryView.swift: session list (sorted by date, mode label, short date); SessionHistoryDetailView (renamed from SessionDetailView to avoid RootView collision) with sections for overview, key topics, action items, decision summary, follow-up subject + draft, stored brief, saved artifact, and notes.
- BriefSectionBox: internal shared card component (titled card with border) used by both history and brief views.
- PreSessionBriefView.swift: read-only brief display with mode icon header, goal, opening framing, focus areas (scope icon), risks (triangle icon), target close (flag icon), document highlights (per-doc with signal tag), and prior session note; pure data-in, zero AppModel dependency.
- OllamaBriefService.swift: OllamaBriefGenerationRequest (model + configuration + documentHighlights + priorSessionNote); OllamaBriefService.generateBrief(from:) async throws -> MeetingBrief; uses modeHelper.preMeetingPromptSection; array-capable JSON schema (OllamaBriefProperty + OllamaBriefItems support type: "array"); merges LLM payload with pre-computed doc highlights; graceful fallback to modeHelper values if LLM fields are empty.
- Build verified clean, zero warnings.

## 2026-04-26 (Phase 2 persistence + prompt layer — BriefInput factory, preMeetingPromptSection, SummaryResult, store helpers)

- BriefInput.from(configuration:snapshot:documentIDs:priorSessions:): static factory on MeetingBriefBuilder.BriefInput; filters DocumentLibrarySnapshot to attached docs internally.
- MeetingModePromptHelper.preMeetingPromptSection(for:hasDocs:hasPriorSession:): new prompt section for AI-backed brief generation; includes mode goal, focus areas, risks line, and context flags.
- MeetingModePromptHelper.preMeetingRisksLine(for:): private helper — concise one-line risk summary per mode used by the section above.
- SummaryResult: new Sendable struct pairing MeetingSummary + StoredFollowUpArtifact.
- PostMeetingSummaryService.generateResult(for:documents:) -> SummaryResult: contains all logic; also constructs StoredFollowUpArtifact from builtDraft.subject + builtDraft.body.
- PostMeetingSummaryService.generateSummary remains unchanged at the call site (thin wrapper over generateResult).
- MeetingSessionStore.saveBrief(_:forSessionID:): load-modify-save for brief field.
- MeetingSessionStore.saveFollowUpArtifact(_:forSessionID:): load-modify-save for followUpArtifact field.
- MeetingSessionStore.saveSummaryResult(_:forSessionID:): writes summary + followUpArtifact in one load-save cycle.
- Build verified clean, zero warnings.

## 2026-04-26 (Phase 2 intelligence layer — MeetingBriefBuilder)

- Created MeetingBriefBuilder.swift with MeetingBrief model (Codable, Sendable, Equatable).
  - MeetingBrief fields: meetingType, meetingGoal, focusAreas, likelyRisks, suggestedNextStep, openingFraming, documentHighlights, priorSessionNote, generatedAt.
  - MeetingBrief.DocumentHighlight: documentName, relevantExcerpt, signalMatch — derived from chunk signal scanning.
- MeetingBriefBuilder.BriefInput: configuration, attachedDocuments, documentChunks, priorSessions.
- Mode-specific output for sales, demo, client-review, interview, internal-sync, general across all six brief sections.
- Document highlights scan chunks for mode success signals and extract a windowed excerpt near the match.
- Prior session note pulls from the most recent completed session of the same type — uses decisionSummary, outcomeNote, or first actionItem in priority order.
- Added optional brief: MeetingBrief? to MeetingSessionRecord — nil for old sessions, no custom decoder required.
- Build verified clean, zero warnings.

## 2026-04-26 (Phase 2 intelligence layer — second pass)

- Unified meeting-mode prompt guidance: removed duplicated inline mode blocks from OllamaConversationService and OpenAIConversationService; both now call MeetingModePromptHelper.systemPromptSection(for:).
- Added followUpSubject as a first-class field on MeetingSummary with a backward-compatible custom Codable decoder (old sessions decode it as "").
- Added StoredFollowUpArtifact (Codable) to MeetingSessionModels and wired it as an optional field on MeetingSessionRecord; old sessions decode it as nil without breaking.
- Created MeetingRecapFormatter.swift: builds a mode-aware structured overview sentence instead of the naive "first 40 words of transcript" approach.
- PostMeetingSummaryService now uses MeetingRecapFormatter for overview, populates followUpSubject from FollowUpDraftBuilder, and drops the unused guidanceTexts variable.
- Build verified clean with zero warnings (swift build).

## 2026-04-26

- Simplified the main app UX into `Start Session`, `History`, and `Settings`.
- Shipped a first clean overlay structure with `Question`, `Points`, `Context`, and `Action`.
- Added a first implementation of overlay state transitions:
  `Idle`, `Listening`, `Question`, `Recovery`, `Answer Ready`, `Speaking`, `Delivered`, and `Paused`.
- Added a first Smart Recovery Mode with short safe answers for missed-context moments.
- Added a buy-time fallback action for live pressure moments.
- Improved lightweight speaker distinction and direct-question detection heuristics.

## 2026-04-26 (Phase 1 live UX and recovery foundation)

- Added meeting-mode templates for `Sales Call`, `Demo`, `Client Review`, `Interview`, `Internal Sync`, and `General`.
- Expanded recovery mode into structured `What Happened` and `They Need` guidance instead of a generic fallback block.
- Added first-run setup readiness guidance and recommended defaults so the user can get to a usable setup faster.
- Expanded post-meeting review with clearer outcome framing, decision summary, and follow-up draft generation.

## 2026-04-26 (Phase 3 live intelligence foundation)

- Added role-aware speaker labels and lightweight live intent detection for pricing, objection, decision, clarification, proof, and next-step moments.
- Added compact coaching surfaces:
  suggested response mode, coaching cue, confidence advice, and live decision cue.
- Added live playbooks for objection, pricing, decision, and next-step moments with concrete steps and one risk to avoid.
- Made live answer shaping itself intent-aware so the generated response structure changes for objection, pricing, proof, decision, and next-step situations.
- Added interruption-aware and low-confidence-aware shaping so live answers become shorter and safer when the user is cut off or context is weak.
- Added explicit interruption recovery guidance for `Stop`, `Clarify`, `Close`, `Reduce Risk`, and `Re-enter` moments.
- Upgraded confidence from a basic heuristic to a signal-based score driven by transcript stability, transcript confidence, question clarity, retrieval strength, interruption state, and answer progress.

## 2026-04-26 (Phase 2 brief parity + coordination layer)

- OpenAIBriefService.swift: `OpenAIBriefGenerationRequest`, `OpenAIBriefError`, `OpenAIBriefService.generateBrief(from:) async throws -> MeetingBrief`; uses chat completions with `response_format: {"type": "json_object"}`; decodes `BriefAIPayload` from `choices[0].message.content`; falls back on `MeetingBriefBuilder().assembleBrief`.
- OllamaBriefService refactored: removed `OllamaBriefPayload`, `assembleBrief`, `fallbackGoal`, `fallbackRisks` — now delegates to shared `BriefAIPayload` + `MeetingBriefBuilder().assembleBrief(from:meetingType:documentHighlights:priorSessionNote:)`.
- `BriefAIPayload: Codable, Sendable` and `MeetingBriefBuilder.assembleBrief(from:meetingType:documentHighlights:priorSessionNote:)` extension added to MeetingBriefBuilder.swift as the shared payload/assembly surface.
- BriefCoordinator.swift: `BriefGenerationStrategy` enum (heuristicOnly / ollama / openAI), `BriefCoordinator.Input`, `build(from:) async -> MeetingBrief` — always returns, AI failures fall back to heuristic silently.
- SessionHistoryCoordinator.swift: `HistoryState` (sessions + documents), `loadState() throws -> HistoryState`, `makeView(from:) -> SessionHistoryView`.
- `MeetingSessionRecord.makeNew(configuration:title:documentIDs:)` static factory added to MeetingSessionModels.swift.
- `MeetingSessionStore` lifecycle helpers added: `loadSession(id:)`, `createSession(_:)`, `endSession(id:at:)`, `updateTitle(_:forSessionID:)`.
- Build clean, zero warnings.

## 2026-04-26 (Phase 2 product intelligence foundation)

- Added MeetingBriefBuilder with a mode-aware `MeetingBrief` model covering goal, focus areas, likely risks, next step framing, opening framing, document highlights, and prior session note.
- Added prompt unification through MeetingModePromptHelper so mode-specific guidance is shared across live generation and future brief generation.
- Added follow-up subject as a first-class summary field and added StoredFollowUpArtifact on session records without breaking old saved sessions.
- Added MeetingRecapFormatter for mode-aware overviews instead of naive transcript truncation.
- Added SummaryResult generation and targeted store helpers for summary, follow-up artifact, and brief persistence.
- Added SessionHistoryView and PreSessionBriefView as isolated, reusable UI surfaces for saved session artifacts and pre-meeting prep.
- Added OllamaBriefService for AI-backed brief generation using the shared pre-meeting prompt surface.

## 2026-04-26 (Launch wiring, privacy, and live calibration surfaces)

- Wired session start to persisted lifecycle helpers and async pre-meeting brief generation.
- Wired session end to summary-result persistence and follow-up artifact saving.
- Replaced the older inline history browser with the coordinator-backed SessionHistoryView flow.
- Added a privacy/transparency settings surface showing local vs external execution, stored data, and Keychain key status.
- Added lightweight response personalization with balanced, safe, assertive, and consultative steering.
- Added lightweight recurring memory from prior sessions of the same meeting type.
- Added meeting-mode-specific focus and risk cues in the live coaching surfaces.
- Added live watchouts for low confidence, speaker uncertainty, interruption, recovery, thin context, external-provider use, and over-talking risk.
- Added direct in-meeting steering controls and session diagnostics for recoveries, low-confidence moments, interruptions, and provider fallbacks.

## 2026-04-26 (Launch-readiness docs and validation support)

- Created the beta validation pack:
  `manual-beta-plan.md`, `live-meeting-checklist.md`, and `privacy-checklist.md`.
- Updated README and product.html to match the current 3-surface product and current privacy/local-first behavior.
- Added backward-compatible session decoding and safer session-store loading behavior for older saved data.
