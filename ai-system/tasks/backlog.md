# Backlog

This backlog captures current gaps, near-term product work, and future differentiation work discussed so far.

## Product Principles

- The user should never feel alone in a meeting.
- The product should reduce thinking, not create more controls.
- The product should earn trust through timing, accuracy, and privacy.
- The live moment matters more than after-the-fact summaries.
- The first paid experience should feel premium, calm, and role-aware.

## Critical Buyer Risks To Solve

- Trust can break from one bad live answer, one confusing overlay moment, or one delay.
- The product can feel replaceable if it does not create a signature "missed context recovery" moment.
- The user may feel overloaded if setup, provider selection, and session control remain too manual.
- Weak speaker understanding can make guidance feel unreliable.
- Generic guidance will not justify purchase for sales, client, or interview workflows.

## P0 Repo And Product Hygiene

### CM-BLG-001 `Testing foundation`
- Add a real `Tests` target so `swift test` passes cleanly.
- Add basic coverage for session lifecycle, overlay state, transcript normalization, and guidance formatting.
- Acceptance:
  `swift test` passes locally with at least a smoke suite.

### CM-BLG-002 `Public repo cleanup`
- Align `product.html` CTA targets with what is actually published in the repo.
- Remove tracked `.DS_Store` from version control and keep it ignored.
- Keep README and product-site messaging aligned with implementation and roadmap.
- Acceptance:
  Public repo has no broken CTA links, no junk files, and consistent product positioning.

## P1 Trust, Speed, And Live Usability

### CM-BLG-014 `Live reliability guardrails`
- Add cooldown and debounce behavior to avoid constant overlay refresh.
- Avoid regenerating during unstable transcript fragments.
- Prevent duplicate guidance loops for the same user moment.
- Acceptance:
  Overlay updates feel stable and low-jitter in real usage.

## P1 Signature Product Experience

## P1 Speaker And Context Accuracy

### CM-BLG-031 `Role-aware speaker labeling`
- Evolve from `You` / `Other` into role labels:
  `Prospect`, `Client`, `Interviewer`, `Manager`, `Teammate`.
- Allow manual correction in session setup and history.
- Acceptance:
  Guidance can refer to the right participant role, not generic transcript blobs.

### CM-BLG-033 `Context window shaping`
- Build a better live context window:
  latest question, previous 1-2 turns, relevant retrieved knowledge, recent user answer.
- Acceptance:
  Guidance is based on the right slice of conversation instead of too much transcript.

## P1 Role-Specific Product Value

### CM-BLG-041 `Sales call specialization`
- Add sales-focused behavior:
  objection handling, pricing moments, next-step framing, pilot framing, urgency vs adoption tradeoffs.
- Acceptance:
  Sales users see clear value that generic assistants do not offer.

### CM-BLG-042 `Demo assistance specialization`
- Add demo-specific guidance:
  redirect to workflow value, answer feature questions, keep flow moving, suggest next workflow to show.
- Acceptance:
  Demo presenters get specific help, not generic call advice.

### CM-BLG-043 `Interview support specialization`
- Add interview-specific guidance:
  connect experience to outcomes, structure examples, keep answers concise, ask strong clarifying questions.
- Acceptance:
  The product supports interview scenarios distinctly from sales calls.

### CM-BLG-044 `Internal meeting support specialization`
- Add internal mode behavior:
  summarize decisions, owner tracking, dependencies, blockers, and alignment follow-ups.
- Acceptance:
  Internal meetings feel less like noise and more like organized execution.

## P2 Reduced User Effort

### CM-BLG-052 `Session auto-start suggestions`
- Detect likely meeting start conditions and suggest starting a session automatically.
- Acceptance:
  Users are less likely to forget to start Cuemate before a real meeting.

## P2 Pre-Meeting Journey

### CM-BLG-061 `Contact and account context`
- Capture participant notes, company notes, relationship stage, and prior context.
- Acceptance:
  Cuemate can prepare the user for recurring external meetings.

### CM-BLG-062 `Meeting goals and success criteria`
- Let users define meeting goal, target outcome, and must-cover points.
- Use these goals to tune live guidance.
- Acceptance:
  Guidance aligns with what the user wants from the meeting.

## P2 In-Meeting Intelligence

### CM-BLG-071 `Objection handling engine`
- Recognize and respond to common objections.
- Especially for sales:
  budget, timing, complexity, trust, switching cost, team adoption.
- Acceptance:
  Cuemate becomes genuinely useful in difficult external conversations.

### CM-BLG-072 `Decision moment detection`
- Detect when the conversation moves toward commitment, approval, escalation, or close.
- Acceptance:
  Guidance shifts toward next-step clarity at the right time.

## P2 Post-Meeting Journey

### CM-BLG-082 `Outcome tracking`
- Track if the meeting produced:
  pilot, follow-up, blocked state, internal action, or open risk.
- Acceptance:
  History becomes operational, not just archival.

## P3 Memory And Personalization

### CM-BLG-090 `Conversation memory`
- Remember recurring contacts, accounts, objections, commitments, and meeting themes across sessions.
- Acceptance:
  Cuemate gets more useful over time for repeat conversations.

### CM-BLG-091 `Personal response style memory`
- Learn whether the user prefers:
  shorter, safer, more assertive, more consultative, or more technical answers.
- Acceptance:
  Guidance gradually matches the user better without manual retuning.

### CM-BLG-092 `Relationship timeline`
- Maintain a simple timeline for recurring people and organizations.
- Acceptance:
  Prior context is available before and during future meetings.

### CM-BLG-093 `Memory controls and privacy boundaries`
- Let the user inspect, edit, disable, or delete saved memory.
- Acceptance:
  Personalization does not undermine the privacy-first promise.

## P3 Trust, Explainability, And Premium Feel

### CM-BLG-100 `Compact why-this-answer hints`
- Show a compact explanation for why Cuemate suggested an answer.
- Keep it one line, optional, and non-distracting.
- Acceptance:
  Users can trust the answer without reading a paragraph.

### CM-BLG-103 `Premium calm visual system`
- Continue improving the visual system for a premium, non-prototype feel.
- Focus on typography, spacing, color restraint, and stable motion.
- Acceptance:
  Users feel they are using a premium product worth paying for.

## P4 Future Differentiation

### CM-BLG-110 `Autonomous background help`
- Allow small useful tasks to be handled in the background by request:
  prep notes, follow-up draft, recap, reminders, and session summaries.
- Acceptance:
  Cuemate starts acting like an assistant, not just a live overlay.

### CM-BLG-111 `Multilingual meeting support`
- Support multilingual transcription, context understanding, and response guidance.
- Acceptance:
  The product expands beyond English-only workflows.

### CM-BLG-112 `Offline-capable mode`
- Strengthen the fully local path for sensitive workflows and unreliable network situations.
- Acceptance:
  Cuemate remains viable in privacy-sensitive or offline settings.

### CM-BLG-113 `Screen and visual context awareness`
- Add optional awareness of slides, shared screens, or on-screen context where platform capabilities allow.
- Acceptance:
  Cuemate understands more than audio and transcript alone.

### CM-BLG-114 `CRM and calendar integrations`
- Pull meeting metadata, attendees, notes, and account context from external systems.
- Acceptance:
  Prep and follow-up become easier without manual copy-paste.

### CM-BLG-115 `Team and manager workflows`
- Support shared best-practice templates, review notes, coaching packs, and team-specific playbooks.
- Acceptance:
  Cuemate becomes more valuable for teams, not only individuals.

## Suggested Initial Execution Order

- Phase 1 and 2 follow-up:
  `CM-BLG-014`, `CM-BLG-031`, `CM-BLG-033`, `CM-BLG-041`, `CM-BLG-042`, `CM-BLG-043`, `CM-BLG-044`, `CM-BLG-052`, `CM-BLG-061`, `CM-BLG-062`, `CM-BLG-082`
- Phase 3:
  `CM-BLG-071`, `CM-BLG-072`, `CM-BLG-090`, `CM-BLG-091`, `CM-BLG-100`
- Future:
  `CM-BLG-092`, `CM-BLG-093`, `CM-BLG-103`, `CM-BLG-110`, `CM-BLG-111`, `CM-BLG-112`, `CM-BLG-113`, `CM-BLG-114`, `CM-BLG-115`

See `tasks/implementation-plan.md` for the execution plan and sequencing.
