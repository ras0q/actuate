import Actuate
import SwiftUI

struct AddCommentExampleView: View {
    let issue: Issue

    @State private var bodyText = ""

    private var addComment = EnvironmentAsyncAction(\.issueRepository) { repository, input in
        try await repository.addComment(input)
    }

    init(issue: Issue) {
        self.issue = issue
    }

    private var addCommentInput: AddCommentInput {
        AddCommentInput(issueID: issue.id, body: bodyText)
    }

    var body: some View {
        AddCommentScreen(
            issue: issue,
            bodyText: $bodyText,
            phase: addComment.phase,
            onSubmit: {
                Task {
                    await addComment.run(input: addCommentInput)
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        AddCommentExampleView(issue: Issue(id: 1, title: "Fix login timeout", status: .open))
    }
    .environment(\.issueRepository, PreviewIssueRepository())
}
