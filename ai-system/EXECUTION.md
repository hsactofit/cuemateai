# Execution

## Core Commands

Build the app:

```bash
swift build
```

Run the app:

```bash
swift run cuemate
```

Run package tests:

```bash
swift test
```

Build the macOS app bundle:

```bash
./scripts/build_macos_app.sh
```

## Current Repo Notes

- `swift build` is the main verified validation command.
- `swift test` currently builds the package but may exit with "no tests found" until a real test target is added.
- The app bundle output path is `dist/Cuemate.app` when the packaging script succeeds.
- Agents should prefer existing scripts and package commands over inventing new local workflows.

