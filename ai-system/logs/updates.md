# Updates Log

## 2026-04-26 (Launch-readiness doc audit — personalization, memory, mode polish)

- README: added preferred answer style to the Settings section description.
- README "What Cuemate Does Today": added preferred answer style, recurring session memory, and mode focus/risk cues in the live coaching card.
- README "Capabilities Roadmap": moved lightweight session continuity, preferred answer style, and mode polish from missing/upcoming into the Available section; reworded "Deeper session memory" upcoming item to reflect that a lightweight version already shipped.
- product.html features grid: added "Preferred Answer Style" and "Session Continuity" feature cards.
- product.html footer roadmap: replaced single "Agentic memory - Upcoming" line with two lines — one for shipped continuity and one for deeper memory still upcoming.
- manual-beta-plan.md: added preferred answer style selector to Setup prerequisites; added recurring memory and mode cue checks to all four scenario pre/live sections; added dedicated Preferred Answer Style test section and Recurring Memory test section.
- live-meeting-checklist.md: added preferred answer style and recurring memory checks to the before-meeting section; added mode focus/risk cue and answer style checks to during-meeting; added three answer-style/memory-related red flags.
- No code changes. Build still clean.

## 2026-04-26 (Beta validation pack + launch hygiene + persistence audit)

- Added `MeetingSessionRecord` explicit memberwise init and backward-compat `init(from:)` — old sessions with missing `followUpNotes`, `guidanceHistory`, or optional fields now decode safely instead of crashing.
- Added `MeetingSessionStore.loadSessionsSafely()` — non-throwing variant that returns [] on any decode error; safe for app startup.
- Added directory auto-creation in `MeetingSessionStore.saveSessions` — first-run no longer fails if sessions directory does not exist yet.
- Added `SessionHistoryCoordinator.loadStateOrEmpty()` — non-throwing convenience for the history tab; delegates to `loadSessionsSafely`.
- Added `BriefCoordinator.Input.make(...)` — auto-selects strategy from available credentials so call sites stay thin.
- Updated `README.md` to reflect the current 3-surface product (Start Session / History / Settings), accurate capabilities list, privacy model, and provider options.
- Updated `product.html` sidebar cards, hero stats, "Three Surfaces" flow section (replacing "Two Clear Flows"), and feature grid to include Pre-meeting Briefs and Privacy Transparency.
- Created `.ai-system/testing/manual-beta-plan.md`, `live-meeting-checklist.md`, and `privacy-checklist.md` for real-meeting validation.
- Verified the package still builds with `swift build` after all changes, zero warnings.

## 2026-04-26 (Phase 2 brief parity + coordination layer)

- Refactored OllamaBriefService to use shared `BriefAIPayload` + `MeetingBriefBuilder().assembleBrief` — removed all duplicate payload/assembly/fallback code.
- Added `BriefAIPayload` and `assembleBrief` extension to MeetingBriefBuilder.swift as the single shared surface for both brief services.
- Created OpenAIBriefService.swift: parallel to OllamaBriefService, uses chat completions with `response_format: json_object`, same preMeetingPromptSection prompt surface, same BriefAIPayload decode + assembleBrief assembly.
- Created BriefCoordinator.swift: `BriefGenerationStrategy` (heuristicOnly / ollama / openAI) + `BriefCoordinator.build(from:) async -> MeetingBrief` — decision logic and AI fallback in one place, not in views.
- Created SessionHistoryCoordinator.swift: thin coordinator for loading history state and vending `SessionHistoryView`.
- Added `MeetingSessionRecord.makeNew(configuration:title:documentIDs:)` static factory.
- Added `MeetingSessionStore` lifecycle helpers: `loadSession`, `createSession`, `endSession`, `updateTitle`.
- Verified the package still builds with `swift build` after all changes, zero warnings.

## 2026-04-26 (Launch wiring pass — session lifecycle + brief/history integration)

- Wired session start to `MeetingSessionRecord.makeNew` + `MeetingSessionStore.createSession`, then layered in async `BriefCoordinator` generation so active sessions now get persisted records plus a generated pre-meeting brief.
- Wired session end to `PostMeetingSummaryService.generateResult`, `MeetingSessionStore.saveSummaryResult`, and `MeetingSessionStore.endSession`, so summary + follow-up artifact persistence now happens through the targeted lifecycle helpers.
- Added `historyState` to AppModel and refreshed it through `SessionHistoryCoordinator`, so the history surface now reads from the coordinator-backed state instead of the older inline history browser.
- Updated the live workspace to show `PreSessionBriefView` when an active session brief is available.
- Verified the package still builds with `swift build` after the launch wiring changes, zero warnings.

## 2026-04-26 (Privacy/transparency UI pass)

- Added privacy summaries to AppModel for response path, transcription path, locally stored data, and privacy boundaries.
- Added a `Privacy And Data` card to settings so users can see when processing stays local, when OpenAI may be used, what is stored locally, and that the OpenAI key lives in Keychain.
- Verified the package still builds with `swift build` after the privacy/transparency UI changes, zero warnings.

## 2026-04-26 (Lightweight response personalization)

- Wired the existing `confidenceMode` preference into live response-mode selection so guidance can bias toward safe, assertive, consultative, or balanced behavior.
- Updated live response shaping so preference influences the final answer form and the next-step suggestion, not just the UI state.
- Added a segmented `Preferred answer style` control in settings plus a matching read in the live coaching card.
- Verified the package still builds with `swift build` after the personalization changes, zero warnings.

## 2026-04-26 (Lightweight recurring memory)

- Added recurring session memory derived from recent completed sessions of the same meeting type.
- The start-session workspace now surfaces recent outcome, follow-through, recurring themes, and recent decision pattern as a small continuity layer.
- Kept the memory layer lightweight by deriving from existing saved sessions instead of introducing a new persistence model.
- Verified the package still builds with `swift build` after the recurring-memory changes, zero warnings.

## 2026-04-26 (Meeting-mode live polish)

- Added explicit meeting-mode focus summaries and meeting-mode risk summaries for sales, demo, client review, interview, internal sync, and general sessions.
- Surfaced those summaries in the live coaching and playbook cards so role-specific framing is visible during testing, not just implied by the meeting type picker.
- Verified the package still builds with `swift build` after the role-specific polish changes, zero warnings.

## 2026-04-26 (Live watchouts)

- Added a compact `Watchouts` surface to the live workspace for low-confidence, speaker-read, interruption, recovery, thin-context, external-provider, and over-talking risk flags.
- The live layer now warns about risky conditions before the user over-trusts the answer, which should make real-meeting testing more dependable.
- Verified the package still builds with `swift build` after the watchout changes, zero warnings.

## 2026-04-26 (In-meeting steering)

- Added direct live controls for `Balanced`, `Safe`, `Assertive`, and `Consultative` response steering inside the session workspace.
- Added AppModel support for switching preferred response style in-session without leaving the live flow.
- Verified the package still builds with `swift build` after the live steering changes, zero warnings.

## 2026-04-26 (Session diagnostics)

- Added lightweight per-session diagnostics for recovery events, low-confidence guidance, interruptions, and provider fallbacks.
- Surfaced those counters in a new `Session Diagnostics` card in the live workspace to make real calibration easier.
- Verified the package still builds with `swift build` after the diagnostics changes, zero warnings.

## 2026-04-28 (Planning sync)

- Pruned clearly finished items from backlog:
  `CM-BLG-060`, `CM-BLG-063`, `CM-BLG-083`, and `CM-BLG-102`.
- Expanded completed to include launch wiring, privacy/transparency, live steering, recurring memory, watchouts, diagnostics, and launch-readiness docs.
- Simplified in-progress so it now shows the true remaining status:
  real-meeting validation, deeper cross-session memory, style learning over time, and test coverage.

## 2026-04-25

- Recreated a local-only `.ai-system` folder for Cuemate so agents can follow shared repo context again.
- Added `.ai-system/` to `.gitignore` to keep agent coordination files out of git.
- Seeded product, architecture, execution, and rules documents based on the current repo structure and messaging.

## 2026-04-26

- Added product roadmap tasks for Smart Recovery Mode, speaker labeling, meeting templates, cleaner overlay states, intent detection, silent coaching, trust-aware guidance, and session memory.
- Expanded the backlog into a detailed PM task list with priorities, buyer risks, task IDs, and a phased implementation plan.
- Implemented the first Phase 1 live-trust slice:
  cleaner three-surface UX, overlay state model, Smart Recovery Mode heuristics, buy-time fallback, safer low-confidence shaping, and basic automatic answer advance behavior.
- Verified the package still builds with `swift build`.
- Attempted to add a local test target, but the current toolchain in this environment does not expose `XCTest` or Swift Testing modules, so test harness work was removed to keep the package healthy.
- Added meeting-mode templates for `Sales Call`, `Demo`, `Client Review`, `Interview`, `Internal Sync`, and `General`.
- Updated local and hosted generation prompts so meeting modes shape the guidance more explicitly.
- Expanded recovery mode to show structured `What Happened` and `They Need` detail in the overlay.
- Added lightweight role-aware speaker labels and live intent detection to the app model and live UI.
- Added first-run setup readiness guidance with recommended defaults and a pre-live checklist in the app UI.
- Expanded post-meeting review output with decision summary, follow-up draft, and clearer outcome framing.
- Verified the package still builds with `swift build` after the latest UX and setup changes.
- Added a compact coaching layer in the live UI:
  suggested response mode, meeting cue, and confidence advice are now derived from live intent and guidance confidence.
- Verified the package still builds with `swift build` after the latest Phase 3 live-intelligence changes.
- Added a deeper live playbook layer for objection, decision, pricing, and next-step moments, including concrete handling steps and one key risk to avoid.
- Verified the package still builds with `swift build` after the latest playbook changes.
- Made live answer shaping itself intent-aware so objection, decision, pricing, proof, and next-step moments now change the generated answer structure and suggested next move.
- Verified the package still builds with `swift build` after the latest answer-shaping changes.
- Added interruption-aware and low-confidence-aware live behavior so objection, decision, pricing, proof, and next-step answers become shorter and safer when the user is cut off or context is weak.
- Verified the package still builds with `swift build` after the latest adaptive-confidence changes.
- Pruned completed tasks from `.ai-system/tasks/backlog.md` so the backlog now reflects only remaining work, while completed details stay preserved in `.ai-system/tasks/completed.md`.
- Added explicit interruption-recovery UX in the live layer:
  re-entry instruction, live `Stop / Clarify / Close / Reduce Risk / Re-enter` cue, and stronger coaching when the user is cut off mid-answer.
- Verified the package still builds with `swift build` after the latest interruption UX changes.
- Recorded a collaboration boundary:
  Claude will continue Phase 2, and Codex will pick up Phase 3 after Phase 2 lands, with explicit non-overlapping file ownership to reduce conflicts.
- Phase 2 UI + AI brief layer (2026-04-26):
  Created SessionHistoryView.swift: session list + SessionHistoryDetailView (renamed to avoid RootView collision); surfaces overview, key topics, action items, decision summary, follow-up subject+draft, stored brief, saved artifact, and notes.
  BriefSectionBox defined as internal shared card component, used by both history and brief views.
  Created PreSessionBriefView.swift: read-only brief display with mode icon, goal, opening, focus areas, risks, target close, document highlights, and prior session note; pure data-in, no AppModel dependency.
  Created OllamaBriefService.swift: OllamaBriefGenerationRequest + OllamaBriefService.generateBrief(from:) async throws; uses preMeetingPromptSection; JSON schema supports array fields (focusAreas, likelyRisks) via OllamaBriefProperty/Items types; merges LLM payload with pre-computed doc highlights; fallback fields from modeHelper if LLM returns empty.
  Build clean, zero warnings.
- Phase 2 persistence + prompt layer (2026-04-26):
  BriefInput.from(configuration:snapshot:documentIDs:priorSessions:) — convenience factory removes call-site boilerplate.
  MeetingModePromptHelper.preMeetingPromptSection(for:hasDocs:hasPriorSession:) — shared AI prompt surface for future brief generation via Ollama/OpenAI.
  SummaryResult + PostMeetingSummaryService.generateResult — produces StoredFollowUpArtifact alongside MeetingSummary; generateSummary unchanged.
  MeetingSessionStore: saveBrief, saveFollowUpArtifact, saveSummaryResult — targeted single-field persistence helpers.
  Build clean, zero warnings.
- Phase 2 MeetingBriefBuilder shipped (2026-04-26):
  Created MeetingBriefBuilder.swift with MeetingBrief Codable model.
  Mode-aware goal, focus areas, likely risks, next-step framing, opening framing, document highlights, and prior session note across all six modes.
  Document highlights scan chunks with modeHelper.successSignals and extract windowed excerpts near signal matches.
  Prior session note draws from decisionSummary → outcomeNote → first actionItem of the most recent same-type completed session.
  Added optional brief: MeetingBrief? to MeetingSessionRecord — backward compatible, nil for old sessions.
  Build clean, zero warnings.
- Phase 2 intelligence layer second pass (2026-04-26):
  Unified prompt guidance into MeetingModePromptHelper (removed duplicate inline blocks from Ollama and OpenAI services).
  Added followUpSubject as a first-class field on MeetingSummary with a backward-compatible custom decoder.
  Added StoredFollowUpArtifact (Codable, optional) to MeetingSessionRecord for future follow-up history view.
  Created MeetingRecapFormatter.swift — mode-aware structured overview replaces naive word-limit truncation.
  PostMeetingSummaryService wired to use new helpers end-to-end.
  Build clean, zero warnings.
- Phase 3 confidence scoring refinement (2026-04-26):
  Replaced the simple confidence heuristic with a signal-based confidence assessment in the live layer.
  Signal quality now considers interruption state, question clarity, transcript stability, transcript confidence, retrieval strength, and answer progress.
  Suggested response mode, live decision cue, and coaching guidance now shift more safely when context is weak and more assertively when context is strong.
  Build clean, zero warnings.
- Planning surface sync (2026-04-26):
  Pruned newly completed work from `.ai-system/tasks/backlog.md`, including the now-shipped confidence scoring item.
  Expanded `.ai-system/tasks/completed.md` so Phase 1, Phase 2, and Phase 3 shipped work is easier to audit.
  Tightened `.ai-system/tasks/in-progress.md` so it reflects only true remaining gaps:
  app-flow wiring for new Phase 2 surfaces, provider parity for AI-backed briefs, session-lifecycle persistence wiring, and deeper live reliability/intelligence tuning.
- Phase 3 reliability and context shaping (2026-04-26):
  Added duplicate-guidance suppression keyed to the live question fingerprint.
  Added stronger unstable-transcript filtering for low-confidence and too-thin transcript fragments.
  Narrowed live generation to a cleaned recent context window instead of the raw full transcript list.
  Added a visible `Context Read` summary in the live coaching UI to make grounding easier to inspect during testing.
  Build clean, zero warnings.
- Phase 3 deeper objection/decision handling (2026-04-26):
  Expanded live objection handling into subtypes for budget, timing, trust, complexity, adoption, and general objection moments.
  Expanded live decision handling into subtypes for approval, owner, timeline, pilot, and general decision moments.
  Updated coaching, playbooks, risk-to-avoid guidance, and live answer shaping so each subtype produces more situation-specific guidance.
  Added a compact `Moment` read in the live UI so the inferred pressure moment is easier to inspect while testing.
  Build clean, zero warnings.
- Phase 3 transition smoothing (2026-04-26):
  Added short state holds around question detection, re-entry after interruption, speaking, and post-answer completion so the overlay does not flicker between states during brief pauses.
  Re-entry now restores into an answer-ready state briefly instead of dropping straight back to generic listening.
  Recent user speech and recent other-speaker turns now influence overlay timing so fast conversation turns feel calmer and more readable.
  Build clean, zero warnings.
- Phase 3 speaker/context trust pass (2026-04-26):
  Improved latest external-turn selection so the live question focuses more reliably on the other participant's most relevant recent line.
  Added stronger user-answer detection cues so transcript segments are less likely to flip incorrectly between `You` and the other role.
  Added a compact `Speaker Read` signal in the live status UI to make speaker inference confidence easier to inspect during testing.
  Build clean, zero warnings.
