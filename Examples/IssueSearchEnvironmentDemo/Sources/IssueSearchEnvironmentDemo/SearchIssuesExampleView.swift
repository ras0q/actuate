import Actuate
import SwiftUI

struct SearchIssuesExampleView: View {
    @State private var keyword = ""
    @State private var status: IssueStatus?
    @State private var sort: IssueSort = .recentlyUpdated

    private var searchIssues = EnvironmentAsyncAction(\.issueRepository, policy: .debounced()) {
        repository, input in
        try await repository.searchIssues(input)
    }

    private var searchInput: SearchIssuesInput {
        SearchIssuesInput(
            keyword: keyword,
            status: status,
            sort: sort,
            page: 1,
            pageSize: 20
        )
    }

    var body: some View {
        SearchIssuesScreen(
            keyword: $keyword,
            status: $status,
            sort: $sort,
            phase: searchIssues.phase,
            onRetry: {
                Task {
                    await searchIssues.run(searchInput, force: true)
                }
            }
        )
        .task(id: searchInput) {
            await searchIssues.run(searchInput)
        }
    }
}

#Preview {
    NavigationStack {
        SearchIssuesExampleView()
    }
    .environment(\.issueRepository, PreviewIssueRepository())
}
