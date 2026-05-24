# Shared Issue Search Demo Sources

Canonical sources for both example packages. Each package symlinks these files
into its `Sources/<PackageName>/` directory:

- `Models.swift` — issue types and input structs
- `IssueRepository.swift` — repository protocol, Environment key, mock implementation
- `DemoViews.swift` — shared SwiftUI screens (`SearchIssuesScreen`, `AddCommentScreen`)

Wiring-specific views remain in each package:

| File | IssueSearchDemo | IssueSearchEnvironmentDemo |
|------|-----------------|----------------------------|
| `SearchIssuesExampleView.swift` | `AsyncAction` | `EnvironmentAsyncAction` |
| `AddCommentExampleView.swift` | `AsyncAction` | `EnvironmentAsyncAction` |
| `IssueSearchView.swift` | init DI | `.environment(\.issueRepository)` |
