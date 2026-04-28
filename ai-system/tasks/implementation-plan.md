# Implementation Plan

This plan turns the backlog into a practical product path. It is intentionally opinionated: the goal is not to build everything at once, but to build the right things in the right order so the product becomes buyable.

## Product Goal

Make Cuemate the meeting assistant people trust in real-time high-pressure conversations, especially when they lose context and need to recover fast.

## Strategy

1. Win trust in the live moment.
2. Make the missed-context recovery experience unforgettable.
3. Reduce user effort until the product feels like autopilot.
4. Specialize deeply for real meeting types instead of staying generic.
5. Build memory, prep, and follow-up after the live core feels dependable.

## Phase 1 `Trust And Signature Experience`

### Goal

Make the live overlay stable, short, safe, and genuinely useful in a real meeting.

### Tasks

- `CM-BLG-010` Ultra-short live responses
- `CM-BLG-011` Overlay state machine
- `CM-BLG-012` Automatic answer advance
- `CM-BLG-013` Overlay simplification
- `CM-BLG-014` Live reliability guardrails
- `CM-BLG-015` Trust-safe fallback mode
- `CM-BLG-020` Smart Recovery Mode
- `CM-BLG-021` Buy-time mode
- `CM-BLG-022` Panic-safe UX
- `CM-BLG-030` You vs other speaker separation
- `CM-BLG-032` Question detection

### Implementation Outline

- Formalize transcript-driven UI states and transitions in the app model.
- Separate answer generation from overlay rendering so UI states remain stable.
- Add recovery-specific heuristics for:
  abrupt speaker handoff, direct user question, pricing phrase, silence after prompt.
- Add confidence-based answer shaping:
  assertive when context is strong, safe when context is weak.
- Improve speaker heuristics before attempting full role-aware labeling.

### Exit Criteria

- Overlay is readable in one glance.
- User usually gets a usable answer within seconds.
- Product feels calmer after pressure moments instead of noisier.

## Phase 2 `Meeting Journey And Product Fit`

### Goal

Make the product feel purpose-built for real meeting workflows, not like a generic assistant.

### Tasks

- `CM-BLG-040` Meeting mode templates
- `CM-BLG-041` Sales call specialization
- `CM-BLG-042` Demo assistance specialization
- `CM-BLG-043` Interview support specialization
- `CM-BLG-044` Internal meeting support specialization
- `CM-BLG-050` One-page first-time setup
- `CM-BLG-051` Auto-configured defaults
- `CM-BLG-053` Low-friction live controls
- `CM-BLG-060` Pre-meeting brief
- `CM-BLG-061` Contact and account context
- `CM-BLG-062` Meeting goals and success criteria
- `CM-BLG-080` Post-meeting recap
- `CM-BLG-081` Follow-up draft generation

### Implementation Outline

- Introduce a session template model that configures:
  meeting type, tone, answer length, intent priorities, and follow-up style.
- Expand session records to include goals, participants, and prep context.
- Build a better history and recap pipeline that ties live help to real outcomes.

### Exit Criteria

- A user can prepare, run, and close a meeting without leaving the product.
- At least one role segment feels deeply understood, likely sales first.

## Phase 3 `Intelligence And Personalization`

### Goal

Move from reactive answer help to context-aware meeting intelligence.

### Tasks

- `CM-BLG-031` Role-aware speaker labeling
- `CM-BLG-033` Context window shaping
- `CM-BLG-070` Live intent detection
- `CM-BLG-071` Objection handling engine
- `CM-BLG-072` Decision moment detection
- `CM-BLG-073` Confidence and delivery coaching
- `CM-BLG-074` Interrupt and recover behavior
- `CM-BLG-082` Outcome tracking
- `CM-BLG-090` Conversation memory
- `CM-BLG-091` Personal response style memory
- `CM-BLG-100` Compact why-this-answer hints
- `CM-BLG-101` Confidence scoring

### Implementation Outline

- Add lightweight classifiers and heuristics first, then upgrade with model-assisted classification where needed.
- Introduce session-to-session memory with strict privacy controls.
- Start with explainability that is short, not verbose.

### Exit Criteria

- Guidance adapts to the meeting, participant role, and user style.
- Cuemate feels increasingly personalized without constant setup.

## Phase 4 `Premium Trust And Differentiation`

### Goal

Turn the product from useful into hard to replace.

### Tasks

- `CM-BLG-092` Relationship timeline
- `CM-BLG-093` Memory controls and privacy boundaries
- `CM-BLG-102` Privacy transparency UI
- `CM-BLG-103` Premium calm visual system
- `CM-BLG-110` Autonomous background help
- `CM-BLG-111` Multilingual meeting support
- `CM-BLG-112` Offline-capable mode
- `CM-BLG-113` Screen and visual context awareness
- `CM-BLG-114` CRM and calendar integrations
- `CM-BLG-115` Team and manager workflows

### Implementation Outline

- Build advanced trust features before scaling integrations.
- Only add broader context channels after the audio-first experience feels strong.

### Exit Criteria

- The product offers a defensible experience beyond note-takers and generic AI chat tools.

## Cross-Cutting Workstreams

### Trust

- Keep response latency low.
- Avoid hallucinated certainty when context is weak.
- Make data boundaries visible and controllable.

### UX

- Reduce visible controls.
- Optimize for one-glance clarity.
- Keep the overlay readable during real screen sharing and live calls.

### Product Fit

- Start with the strongest wedge:
  sales and client-facing meetings.
- Validate signature moments before broadening into every meeting type.

### Quality

- Add tests around state transitions, guidance shaping, and session persistence.
- Validate with simulated transcripts before every UX iteration.

## Recommended Next Build Order

1. `CM-BLG-020` Smart Recovery Mode
2. `CM-BLG-030` You vs other speaker separation
3. `CM-BLG-011` Overlay state machine
4. `CM-BLG-015` Trust-safe fallback mode
5. `CM-BLG-040` Meeting mode templates
6. `CM-BLG-070` Live intent detection
7. `CM-BLG-060` Pre-meeting brief
8. `CM-BLG-080` Post-meeting recap

## Tasks To Explicitly Defer Until Core Trust Is Strong

- Broad integrations
- Team workflow features
- Full multilingual support
- Screen and visual context awareness
- Heavy autonomous background behavior

These are valuable, but they should not come before the core live experience becomes dependable enough for paid adoption.
