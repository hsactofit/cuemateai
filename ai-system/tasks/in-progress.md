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

- `CM-BLG-041` Sales call specialization: objection handling, pricing moments, next-step framing, and pilot framing tuned for sales mode. The role/context foundation is now in place to make this impactful.
- `CM-BLG-043` Interview support specialization: connect-to-outcomes framing, STAR structure, and concise-answer coaching for interview mode.
- Run `.ai-system/testing/manual-beta-plan.md` and `.ai-system/testing/live-meeting-checklist.md` against the updated role/context prompt structure to verify guidance quality in real scenarios.
- Consider `CM-BLG-052` (session auto-start suggestions) after role-specific specialization is solid.
