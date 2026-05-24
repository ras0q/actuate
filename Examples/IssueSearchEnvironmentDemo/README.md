# Actuate Environment Example

SwiftUI sample app that wires `AsyncAction` through `EnvironmentAsyncAction` and SwiftUI `Environment`.

## iOS App

Open the shared examples workspace:

```bash
open Examples/ActuateExamples.xcworkspace
```

1. Scheme: **IssueSearchEnvironmentDemoApp**
2. Destination: an **iPhone Simulator**
3. Run with ⌘R

## Wiring pattern

`EnvironmentAsyncAction` reads a dependency from `Environment`, keeps the backing
`Actuator` inside a `DynamicProperty` holder, and closes over the dependency
in the stored operation.

```swift
private var searchIssues = EnvironmentAsyncAction(\.issueRepository, policy: .debounced()) {
    repository, input in
    try await repository.searchIssues(input)
}
```

The root view injects the repository:

```swift
.environment(\.issueRepository, PreviewIssueRepository())
```

## Build the library only

```bash
cd Examples/IssueSearchEnvironmentDemo
swift build
```
