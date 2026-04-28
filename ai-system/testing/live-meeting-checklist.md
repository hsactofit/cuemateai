# Live Meeting Checklist

Use this immediately before and after a real meeting to validate behavior in production conditions.

---

## Before the meeting (5 minutes out)

- [ ] App is open and on the Start Session screen
- [ ] Meeting type is set correctly for this session
- [ ] Documents attached (if relevant)
- [ ] Pre-meeting brief is visible and reads correctly for this mode
  - Goal makes sense for this session
  - Focus areas are relevant
  - Opening framing gives a useful entry point
  - Document highlights reference the attached material (if docs attached)
  - Prior session note references the last same-type session (if one exists)
- [ ] If prior sessions of this type exist: recurring memory card shows recent outcome/themes (not blank, not placeholder text)
- [ ] Preferred answer style is set to match how you want to show up in this meeting
- [ ] Provider setting confirmed: Heuristic / Ollama / OpenAI
- [ ] Microphone test passes (transcription path shows text)
- [ ] Overlay position is correct relative to camera/screen

---

## During the meeting (after starting)

- [ ] Overlay activates and shows a question within 10–15 seconds of conversation starting
- [ ] Questions are accurate to what is being asked
- [ ] Answers are structured and mode-appropriate (not generic filler)
- [ ] Live coaching card shows mode focus cue specific to this meeting type (not generic)
- [ ] Live coaching card shows mode risk cue specific to this meeting type
- [ ] Answer style matches the preferred style set in Settings (assertive → confident framing, safe → hedged, etc.)
- [ ] Action guidance makes sense for the meeting type
- [ ] Intent detection fires correctly:
  - Pricing/budget moment → shorter, safer answer shape
  - Objection moment → objection playbook visible
  - Decision moment → decision framing visible
  - Next-step moment → close framing visible
- [ ] Recovery mode activates when context is thin or transcript is unstable
- [ ] Buy-time fallback available when needed
- [ ] Confidence indicator reflects actual clarity of the conversation
- [ ] Speaker labels distinguish You from the other participant reasonably well
- [ ] No crash or freeze during the session

---

## After the meeting (within 5 minutes of ending)

- [ ] End session
- [ ] Summary generates without crash
- [ ] Overview sentence captures what the session was actually about
- [ ] Action items include real commitments discussed (if any)
- [ ] Decision summary is non-empty if a decision was reached
- [ ] Follow-up draft subject line is appropriate to this meeting type
- [ ] Follow-up draft body is usable with light editing
- [ ] Session appears in History tab immediately
- [ ] All fields load correctly in the history detail view
- [ ] Brief used is visible in the session history detail

---

## Red flags to log immediately

- Overlay shows a question that is completely wrong or from a different speaker
- Answer is generic and ignores the actual question context
- Answer style does not reflect the preferred style setting
- Recurring memory shows blank or placeholder text when prior sessions exist
- Mode focus/risk cues are generic instead of mode-specific
- Session ends but does not appear in History
- Summary is empty or only shows filler text
- Follow-up draft references the wrong company, person, or topic
- App crashes or freezes at any point

---

## Post-session sanity check (re-launch)

- [ ] Re-launch app
- [ ] Session from this meeting is still in History
- [ ] All artifacts are intact: summary, follow-up, brief, notes
