# Privacy Checklist

Validates Cuemate's local-first claims and transparency behaviors.

---

## Local storage boundaries

- [ ] Sessions, transcripts, and summaries are written to `~/Library/Application Support/Cuemate/`
- [ ] Documents are stored in the local App Support directory
- [ ] Configuration is stored locally — no sync to external service
- [ ] No files are written outside App Support or the user's chosen document path
- [ ] App does not create network connections on launch when provider is set to Heuristic

---

## OpenAI API key handling

- [ ] Key is stored in macOS Keychain, not in a config file or User Defaults
- [ ] Key does not appear in plaintext in `~/Library/Application Support/Cuemate/` or any log
- [ ] Removing the key from Settings stops any OpenAI requests immediately
- [ ] App functions correctly with no key set (heuristic fallback works)

---

## Provider isolation

- [ ] Heuristic mode: confirm no outbound network connections via Activity Monitor or Little Snitch
- [ ] Ollama mode: confirm only `127.0.0.1:11434` is contacted (local)
- [ ] OpenAI mode: confirm only `api.openai.com` is contacted — no other external hosts
- [ ] If OpenAI request fails: app falls back to heuristic brief without crashing or exposing the key

---

## Transcription path

- [ ] Apple Speech: audio processed by Apple's on-device framework — no audio file written to disk
- [ ] `whisper.cpp`: audio processed locally — no audio sent to a remote server
- [ ] No audio file is persisted after transcription (only the text transcript is stored)

---

## Privacy transparency UI

- [ ] Settings shows a Privacy And Data section
- [ ] Section explains which response/guidance paths are local
- [ ] Section explains when OpenAI may be contacted
- [ ] Section explains what is stored locally
- [ ] Section explains where the OpenAI key lives (Keychain)
- [ ] Content in the section matches actual app behavior (verified against above checks)

---

## Session deletion behavior

- [ ] Deleting a session (if feature exists) removes the record from the JSON store
- [ ] No orphaned transcript or artifact files remain after deletion
- [ ] Re-launch confirms deletion is persistent

---

## Sensitive session test

Run a session with sensitive-sounding content (e.g. mention salary, budget numbers, personal names):
- [ ] No content appears in any network request log (if OpenAI is off)
- [ ] Content is not visible outside the local session JSON file
- [ ] Content does not appear in crash logs or diagnostic output

---

## Notes

Log any privacy gaps, unexpected network calls, or transparency UI discrepancies here.
