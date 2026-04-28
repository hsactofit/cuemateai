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

- **Run real-meeting validation**: all P1/P2/P3 items are now built. Run `.ai-system/testing/manual-beta-plan.md` and `.ai-system/testing/live-meeting-checklist.md` against the full prompt stack.
- `CM-BLG-052` Session auto-start suggestions: detect likely meeting start and suggest starting a session.
- `CM-BLG-100` Compact why-this-answer hints: show a one-line explanation for why Cuemate suggested the answer.
- `CM-BLG-101` Confidence scoring: surface a more visible confidence indicator so the user knows when to trust the answer vs. fall back.
- `CM-BLG-103` Premium calm visual system: typography, spacing, and color refinement pass.
