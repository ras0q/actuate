import SwiftUI

/// Root view exposed to the iOS app target.
public struct IssueSearchView: View {
    private let issueRepository: any IssueRepository = PreviewIssueRepository()

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                NavigationLink("Debounced Search") {
                    SearchIssuesExampleView(issueRepository: issueRepository)
                }
                NavigationLink("Add Comment (.onDemand)") {
                    AddCommentExampleView(
                        issue: Issue(id: 1, title: "Fix login timeout", status: .open),
                        issueRepository: issueRepository
                    )
                }
            }
            .navigationTitle("Actuate Examples")
        }
    }
}

#Preview {
    IssueSearchView()
}
