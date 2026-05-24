import Actuate
import SwiftUI

/// Root view exposed to the iOS app target.
public struct IssueSearchView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                NavigationLink("Debounced Search") {
                    SearchIssuesExampleView()
                }
                NavigationLink("Add Comment (.onDemand)") {
                    AddCommentExampleView(
                        issue: Issue(id: 1, title: "Fix login timeout", status: .open)
                    )
                }
            }
            .navigationTitle("Actuate Examples (Environment)")
        }
        .environment(\.issueRepository, PreviewIssueRepository())
    }
}

#Preview {
    IssueSearchView()
}
