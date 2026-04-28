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

- **Run real-meeting validation**: the full prompt stack (role labels, context window, goals, participant context, intent-specific tactics) is in place. Run `.ai-system/testing/manual-beta-plan.md` and `.ai-system/testing/live-meeting-checklist.md` to surface any trust breaks.
- `CM-BLG-090` Conversation memory: remember recurring contacts, objections, and commitments across sessions using the `sessionOutcome` + `participantName`/`participantCompany` now stored per session.
- `CM-BLG-091` Personal response style memory: learn whether the user prefers shorter/safer/more-assertive answers over time.
- `CM-BLG-052` Session auto-start suggestions: detect likely meeting start and prompt the user to start a session.
