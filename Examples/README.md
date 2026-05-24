# Actuate Examples

Two iOS sample apps demonstrating different Actuate wiring patterns.

## Open in Xcode

```bash
open Examples/ActuateExamples.xcworkspace
```

The workspace includes both app projects and their Swift packages:

| App | Scheme | Wiring |
|-----|--------|--------|
| **IssueSearchDemoApp** | `IssueSearchDemoApp` | `AsyncAction` with init-based dependency injection |
| **IssueSearchEnvironmentDemoApp** | `IssueSearchEnvironmentDemoApp` | `EnvironmentAsyncAction` with SwiftUI `Environment` |

Select a scheme from the toolbar, choose an iPhone Simulator, and run with ⌘R.

Requires iOS 17+ / Xcode 16+.

## Package layout

```text
Examples/
├── ActuateExamples.xcworkspace
├── Shared/IssueSearchDemo/        # Shared sources (symlinked into both packages)
│   ├── Models.swift
│   ├── IssueRepository.swift
│   └── DemoViews.swift
├── IssueSearchDemo/                 # AsyncAction + init DI
│   ├── Package.swift
│   ├── Sources/IssueSearchDemo/
│   └── IssueSearchDemoApp/
└── IssueSearchEnvironmentDemo/    # EnvironmentAsyncAction
    ├── Package.swift
    ├── Sources/IssueSearchEnvironmentDemo/
    └── IssueSearchEnvironmentDemoApp/
```

Both example packages symlink `Models.swift`, `IssueRepository.swift`, and
`DemoViews.swift` from `Shared/IssueSearchDemo/`. Each package keeps only its
wiring-specific views (`SearchIssuesExampleView`, `AddCommentExampleView`,
`IssueSearchView`).

## Build libraries only

```bash
cd Examples/IssueSearchDemo && swift build
cd Examples/IssueSearchEnvironmentDemo && swift build
```

## Run tests

Only `IssueSearchDemo` includes package tests:

```bash
cd Examples/IssueSearchDemo && swift test
```
