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

- `CM-BLG-042` Demo assistance specialization: redirect to workflow value, feature gap pivots, pacing the demo with check-in questions.
- `CM-BLG-044` Internal meeting specialization: decision-forcing, owner tracking, blocker surfacing.
- `CM-BLG-061` Contact and account context: capture participant notes, company notes, relationship stage in session setup so briefs and guidance are more personalized.
- Run `.ai-system/testing/manual-beta-plan.md` and `.ai-system/testing/live-meeting-checklist.md` against the full intent-aware prompt stack to verify guidance quality in real scenarios.
- `CM-BLG-052` (session auto-start suggestions) is a good UX follow-up once the core guidance quality is validated.
