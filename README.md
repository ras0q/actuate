# Actuate

Async phase management for SwiftUI — one input-driven operation at a time.

`AsyncAction` tracks `idle`, `loading`, `success`, and `failure` through `AsyncPhase`. Debounce, duplicate skipping, previous-result retention, and automatic cancellation are controlled by `AsyncActionPolicy`.

Typical uses: search, submit, and reload.

Requires Swift 6+, iOS 17+, macOS 14+, Observation, and SwiftUI.

## Usage

Create an `AsyncAction` for the async work, call `run(_:)`, and render UI from `phase`.

```swift
private var loadUser = AsyncAction { userID in
    try await userRepository.fetchUser(userID)
}

Button("Load") {
    Task {
        await loadUser.run(userID)
    }
}

switch loadUser.phase {
case .idle:
    Text("Tap Load")
case .loading:
    ProgressView()
case .success(let user):
    Text(user.name)
case .failure(let error, _):
    Text(error.localizedDescription)
}
```

### Debounced search

```swift
private var searchIssues: AsyncAction<SearchIssuesInput, [Issue]>

init(issueRepository: any IssueRepository) {
    searchIssues = AsyncAction(policy: .debounced()) { input in
        try await issueRepository.searchIssues(input)
    }
}

private var searchInput: SearchIssuesInput { ... }

var body: some View {
    content
        .task(id: searchInput) {
            await searchIssues.run(searchInput)
        }
}
```

### Submit on button tap

```swift
private var addComment: AsyncAction<AddCommentInput, IssueDetail>

init(issueRepository: any IssueRepository) {
    addComment = AsyncAction { input in
        try await issueRepository.addComment(input)
    }
}

Button("Submit") {
    Task {
        await addComment.run(addCommentInput)
    }
}
.disabled(addComment.phase.isLoading)
```

### Environment dependency

```swift
private var searchIssues = EnvironmentAsyncAction(\.issueRepository, policy: .debounced()) {
    repository, input in
    try await repository.searchIssues(input)
}
```

### Retry

```swift
Button("Retry") {
    Task {
        await searchIssues.run(searchInput, force: true)
    }
}
```

## Phase

Render UI from `phase`:

```swift
switch searchIssues.phase {
case .idle:
    ContentUnavailableView("Search issues", systemImage: "magnifyingglass")
case .loading(let previous):
    if let previous { issueList(previous) } else { ProgressView() }
case .success(let issues):
    issueList(issues)
case .failure(let error, let previous):
    if let previous { issueList(previous) }
    Text(error.localizedDescription)
}
```

Convenience accessors: `isIdle`, `isLoading`, `output`, `previous`, `error`.

## Policy

| Preset | Typical use |
|--------|-------------|
| `.onDemand` | Fetch, submit, save, delete (default) |
| `.refresh` | Reload while keeping the last result visible |
| `.debounced(for:)` | Search, filter, autocomplete (default 300ms) |

Use `.custom(...)` when you need a specific combination of debounce, duplicate removal, and previous-result retention.

## Design

Each new run supersedes the previous one: in-flight tasks are cancelled, and stale results do not update `phase`. That behavior matters for search and other input that changes faster than the network.

## Examples

See [./Examples/](./Examples/)
