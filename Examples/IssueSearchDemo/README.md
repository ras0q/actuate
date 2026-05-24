# Actuate Example

SwiftUI sample app that wires `AsyncAction` through init-based dependency injection.

## iOS App

Open the shared examples workspace:

```bash
open Examples/ActuateExamples.xcworkspace
```

The IssueSearchDemo library exposes a single public view: `IssueSearchView`. Individual demo screens such as `SearchIssuesExampleView` and `AddCommentExampleView` are internal to the package.

1. Scheme: **IssueSearchDemoApp**
2. Destination: an **iPhone Simulator**
3. Run with ⌘R

The Xcode project links the local `IssueSearchDemo` Swift package (`Examples/IssueSearchDemo/Package.swift`), which depends on `Actuate`.

If signing fails, set your **Development Team** in the IssueSearchDemoApp target settings.

Requires iOS 17+ / Xcode 16+.

## Package layout

```text
Examples/IssueSearchDemo/
├── Package.swift
├── Sources/IssueSearchDemo/
│   ├── Models.swift              -> ../../../Shared/IssueSearchDemo/Models.swift
│   ├── IssueRepository.swift   -> ../../../Shared/IssueSearchDemo/IssueRepository.swift
│   ├── DemoViews.swift           -> ../../../Shared/IssueSearchDemo/DemoViews.swift
│   ├── SearchIssuesExampleView.swift   # AsyncAction wiring
│   ├── AddCommentExampleView.swift
│   └── IssueSearchView.swift
└── IssueSearchDemoApp/
    ├── IssueSearchDemoApp.xcodeproj
    └── IssueSearchDemoApp/
```

See also `Examples/IssueSearchEnvironmentDemo` for the `EnvironmentAsyncAction` variant.
Both apps are in `Examples/ActuateExamples.xcworkspace`.

## Build the library only

```bash
cd Examples/IssueSearchDemo
swift build
```

## Run tests

```bash
cd Examples/IssueSearchDemo
swift test
```

Tests cover the mock `PreviewIssueRepository` and the AsyncAction wiring patterns used by the example screens.

## Screens

| Screen | View | Description |
|--------|------|-------------|
| **Examples hub** | `IssueSearchView` | Public root with navigation to demos |
| **Debounced Search** | `SearchIssuesExampleView` | Input-driven search with `.debounced()` and `.task(id:)` |
| **Add Comment** | `AddCommentExampleView` | Side-effect operation with default `.onDemand` policy |

## Wiring pattern

`AsyncAction` keeps the backing `Actuator` inside a `DynamicProperty` holder, while the view
receives dependencies in `init` and closes over them in the stored operation.

```swift
private var searchIssues: AsyncAction<SearchIssuesInput, [Issue]>

init(issueRepository: any IssueRepository) {
    self.searchIssues = AsyncAction(policy: .debounced()) { input in
        try await issueRepository.searchIssues(input)
    }
}
```

## Things to try

- Debounced search that follows keyword input
- Previous results while loading
- Type `fail` to trigger failure phase and Retry (`force: true`)
- Submit button side-effect action

The repository is an in-memory `PreviewIssueRepository`.
