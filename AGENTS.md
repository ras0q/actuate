# AGENTS.md

Guidance for agents working in this repository.

## Language

- Write **all README files in English**.
- Write **all code comments in English** (including doc comments, inline comments, and example comments).
- Keep user-facing strings in examples and UI in English unless the task explicitly requires another language.

## Project overview

Actuate is a Swift package for async phase management in SwiftUI — one input-driven operation at a time.

Lead with **phase** (idle / loading / success / failure) and **policy** (debounced, refresh, onDemand). Do not lead with "View-local" or "latest-wins"; treat cancellation and stale-result prevention as design details.

Actuate is scoped to a single async pipeline (search, submit, reload).

### Modules

- `ActuateCore` — `AsyncPhase`, `AsyncActionPolicy`, and `Actuator` (no SwiftUI dependency)
- `ActuateSwiftUI` — `AsyncAction`, `EnvironmentAsyncAction`
- `Actuate` — umbrella module

### Examples

- `Examples/Shared/IssueSearchDemo` — models, mock repository, and shared UI (symlinked)
- `Examples/IssueSearchDemo` — `AsyncAction` wiring with init-based DI
- `Examples/IssueSearchEnvironmentDemo` — `EnvironmentAsyncAction` wiring with SwiftUI `Environment`
- `Examples/ActuateExamples.xcworkspace` — Xcode workspace with both iOS app targets

Open the examples workspace:

```bash
open Examples/ActuateExamples.xcworkspace
```

## Conventions

- Follow existing module boundaries and naming.
- Prefer minimal, focused diffs.
- Do not add architecture layers beyond Actuate v1 scope (no ViewModel, Store, Reducer, etc.).
- Run `swift format -ir .`, `swift format lint -rs.`, `swift build` and `swift test` after substantive changes.
