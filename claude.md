# HelloFit trainer app (Flutter) — see `../claude.md`

**Project instructions live in `../claude.md` (a short index) and `../state/`. Read those.**

Most relevant here: `../state/frontend/trainer-app.md` (what is built, and the two open
client questions), `../state/frontend-conventions.md` (structure + shared tokens),
`../state/working-order.md`, `../state/commands.md`.

This file deliberately holds no instructions of its own — it used to be a full copy of the
root file and silently went stale. Claude Code loads the *nearest* `claude.md`, so a
session working in this directory was getting that stale text. Keep this file a pointer.

The one rule that matters most here, repeated because this is the directory it governs:

> **Convert, never design.** The client supplied 74 HTML pages in `../Trainer app screen/`.
> Every screen in this app is a 1:1 transcription of one of them — the CSS numbers are the
> spec. Do not invent a screen, a layout, a component or a colour that is not in that pack,
> and do not convert a page that is outside the PDF's §4.1–4.10 without asking.

Was `instructor_app/` until 19 Nov 2026. `android/`, `ios/` and `instructor_app.iml` still
carry the old id.

Day-to-day history is in `../worklog/`. Read the latest entry before trusting `../state/`.
