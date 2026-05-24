import Actuate
import SwiftUI

struct SearchIssuesExampleView: View {
    @State private var keyword = ""
    @State private var status: IssueStatus?
    @State private var sort: IssueSort = .recentlyUpdated

    private var searchIssues: AsyncAction<SearchIssuesInput, [Issue]>

    init(issueRepository: any IssueRepository) {
        self.searchIssues = AsyncAction(policy: .debounced()) { input in
            try await issueRepository.searchIssues(input)
        }
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
                    await searchIssues.run(input: searchInput, force: true)
                }
            }
        )
        .task(id: searchInput) {
            await searchIssues.run(input: searchInput)
        }
    }
}

#Preview {
    NavigationStack {
        SearchIssuesExampleView(issueRepository: PreviewIssueRepository())
    }
}
