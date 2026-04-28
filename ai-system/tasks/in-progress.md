# In Progress

- Collaboration split:
  Claude is now mostly in docs, audit, and validation support work. Codex owns active live-product tuning in `AppModel.swift` and `RootView.swift`.
- Phase 1 trust refinement:
  Core trust foundations are in place. What remains is live validation, edge-case tuning, and stability polish.
- Phase 2 product-fit foundation:
  Phase 2 and launch hygiene are effectively complete.
  What is left here is not implementation-heavy:
  run the real-meeting beta validation pack and fix anything it surfaces.
- Phase 3 live intelligence foundation:
  The live product is feature-rich enough for serious beta.
  What is next:
  deeper cross-session memory, better learning of user style over time, and real-meeting tuning of confidence/speaker/interruption behavior using the new diagnostics and watchouts.

## Next Focus

- `CM-BLG-031` Role-aware speaker labeling: evolve `You` / `Other` into role labels (`Prospect`, `Client`, `Interviewer`, etc.) so guidance can reference the right participant.
- `CM-BLG-033` Context window shaping: build a better live context window (latest question + 1–2 prior turns + retrieved knowledge) instead of relying on the full raw transcript.
- Run `.ai-system/testing/manual-beta-plan.md` and `.ai-system/testing/live-meeting-checklist.md` against the updated guardrails.
- Decide whether to continue with `CM-BLG-041` (sales specialization) or `CM-BLG-052` (session auto-start) after speaker/context work.
