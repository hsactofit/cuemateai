# Manual Beta Plan

Practical scenarios for validating Cuemate end-to-end across the four core meeting types.
Run each scenario in a real or simulated meeting. Mark pass / fail / note.

---

## Setup prerequisite (run once)

- [ ] `swift build` passes with zero warnings
- [ ] App launches and reaches the Start Session screen without crash
- [ ] Settings shows transcription path selector (Apple Speech / whisper.cpp)
- [ ] Settings shows provider selector (Heuristic / Ollama / OpenAI)
- [ ] Settings shows preferred answer style selector (Balanced / Safe / Assertive / Consultative)
- [ ] Privacy And Data card is visible in Settings and content is accurate
- [ ] OpenAI API key field in Settings stores/retrieves from Keychain (verify no plaintext write)

---

## Scenario A — Sales Call

**Goal:** Qualify path forward; confirm persistence, brief, and follow-up.

### Pre-session
- [ ] Select meeting type: Sales Call
- [ ] Attach one document (e.g. a prospect one-pager)
- [ ] Brief loads with: goal, focus areas (3–5), likely risks (2–3), opening framing, document highlight
- [ ] If a prior sales session exists: prior session note appears in brief
- [ ] If prior sales sessions exist: start-session workspace shows recurring memory (recent outcome, themes, decision pattern)

### Live session
- [ ] Start session — overlay activates
- [ ] Live coaching card shows mode focus cue (sales-specific framing, not generic)
- [ ] Live coaching card shows mode risk cue (sales-specific risk, not generic)
- [ ] Set preferred style to Assertive → answers lean more confident and direct
- [ ] Set preferred style to Safe → answers become more hedged and careful
- [ ] Speak or simulate a budget/pricing question → overlay shows intent-aware answer
- [ ] Simulate an objection ("we're not sure about timing") → objection subtype guidance appears
- [ ] Simulate a decision moment → decision framing appears
- [ ] Buy-time fallback available during low-confidence moment

### Post-session
- [ ] End session
- [ ] Summary generates with: overview, key topics, action items, decision summary
- [ ] Follow-up draft has subject line + body
- [ ] History tab shows the session with all artifacts
- [ ] Brief used for the session is visible in the history detail
- [ ] Re-launch app → session still visible in History (persistence check)

---

## Scenario B — Client Review

**Goal:** Confirm progress, surface open risks, close on one action.

### Pre-session
- [ ] Select meeting type: Client Review
- [ ] Attach a progress document or status deck
- [ ] Brief goal reads: confirm progress / surface top open risk / close on one accountable action
- [ ] Focus areas include review-appropriate signals (delivery, scope, timeline)
- [ ] Opening framing mentions acknowledging progress
- [ ] If prior client-review sessions exist: recurring memory shows recent outcome/themes

### Live session
- [ ] Start session
- [ ] Live coaching card shows client-review mode focus and risk cues (not sales or generic)
- [ ] Simulate a concern ("we feel the progress isn't visible") → concern/trust subtype guidance
- [ ] Simulate a timeline question → timeline handling guidance appears
- [ ] Recovery mode activates correctly on a low-confidence/missed-context moment

### Post-session
- [ ] Summary action items reflect any commitments discussed
- [ ] Decision summary is non-empty if a decision was simulated
- [ ] Follow-up draft subject line is appropriate to a client review

---

## Scenario C — Interview

**Goal:** Role-fit case; strong example; defined next step.

### Pre-session
- [ ] Select meeting type: Interview
- [ ] Brief goal: make role-fit case clearly; leave with a defined next step
- [ ] Likely risks include: unprepared example, narrower requirements
- [ ] Opening framing mentions confirming the role and 90-day success view
- [ ] If prior interview sessions exist: recurring memory shows recent themes/outcomes

### Live session
- [ ] Start session
- [ ] Live coaching card shows interview mode focus and risk cues
- [ ] Set preferred style to Consultative → answers feel more considered and narrative
- [ ] Simulate a behavioral question → answer is structured, not generic
- [ ] Simulate a gap/experience question → answer is safe and honest, not overconfident
- [ ] Suggested next step guidance available before session end

### Post-session
- [ ] Summary captures the key topics discussed
- [ ] Follow-up draft is appropriate tone for a post-interview note
- [ ] Session visible and complete in History

---

## Scenario D — Internal Sync

**Goal:** Align on decision; confirm ownership; unblock critical path.

### Pre-session
- [ ] Select meeting type: Internal Sync
- [ ] Brief names: decision to reach, ownership confirmation, blocker removal
- [ ] Focus areas include: decision, ownership, dependencies
- [ ] If prior internal-sync sessions exist: recurring memory shows recent decision patterns

### Live session
- [ ] Start session
- [ ] Live coaching card shows internal-sync mode focus and risk cues (not sales or generic)
- [ ] Simulate a blocker statement → blocker subtype guidance fires
- [ ] Simulate an ownership ambiguity → owner decision guidance fires
- [ ] Confidence adjusts correctly between clear and ambiguous transcript moments

### Post-session
- [ ] Decision summary is populated
- [ ] Action items include an owner and a rough deadline (if simulated)
- [ ] History detail view shows the session cleanly

---

## Persistence regression test (run after all scenarios)

- [ ] Re-launch app — all 4 scenario sessions visible in History
- [ ] Each session detail shows: overview, action items, follow-up subject, follow-up body, brief used
- [ ] No sessions are missing or corrupted after re-launch
- [ ] Old sessions (from before brief/followUpArtifact fields) still decode without crash (if any exist)

---

## Provider parity test

Run Scenario A twice — once with Ollama, once with OpenAI brief generation:

| Check | Ollama | OpenAI |
|---|---|---|
| Brief generated without crash | | |
| meetingGoal is non-empty | | |
| focusAreas has 3–5 items | | |
| likelyRisks has 2–3 items | | |
| openingFraming is non-empty | | |
| Fallback to heuristic if provider unavailable | | |

---

## Preferred answer style test

Verify that the segmented style control changes live behavior. Run with a repeatable question (e.g. "what's the plan?") across styles:

| Style | Expected behavior |
|---|---|
| Balanced | Moderate confidence, balanced structure |
| Safe | Hedged, shorter, avoids strong claims |
| Assertive | Confident framing, direct next step |
| Consultative | Narrative, considered, explores options |

- [ ] Style change takes effect without restarting the session
- [ ] Preferred style is saved and restored on re-launch
- [ ] Style is visible in the live coaching card during a session

---

## Recurring memory test

Run two sessions of the same type back to back:

- [ ] Session 1: complete a full sales session with a decision made and an action item
- [ ] Session 2: start a new sales session — recurring memory card should show:
  - Recent outcome from Session 1
  - Any recurring themes detected
  - Decision pattern if applicable
- [ ] Memory is absent when no prior same-type session exists (no crash, no empty placeholder)

---

## Notes

Record any unexpected behavior, edge cases, or crashes here during testing.
