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

- `CM-BLG-062` Meeting goals and success criteria: let users define meeting goal, target outcome, and must-cover points; use these goals to tune live guidance and pre-meeting brief.
- `CM-BLG-082` Outcome tracking: track if the meeting produced pilot, follow-up, blocked state, internal action, or open risk so history becomes operational.
- Run `.ai-system/testing/manual-beta-plan.md` and `.ai-system/testing/live-meeting-checklist.md` — the full intent/role/context prompt stack is now in place and ready for real validation.
- `CM-BLG-052` (session auto-start suggestions) is a UX polish item to consider after outcome tracking.
