# Backlog

Completed items have been removed — see `tasks/completed.md` for the full record.
All P0–P3 items are complete. What remains is P4 future-differentiation work.

## Product Principles

- The user should never feel alone in a meeting.
- The product should reduce thinking, not create more controls.
- The product should earn trust through timing, accuracy, and privacy.
- The live moment matters more than after-the-fact summaries.
- The first paid experience should feel premium, calm, and role-aware.

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

## Next Action

All P0–P3 work is shipped. Before starting P4:
- Run `.ai-system/testing/manual-beta-plan.md` against the full prompt stack.
- Run `.ai-system/testing/live-meeting-checklist.md` in a real meeting.
- Fix anything surfaced, then pick a P4 item.
