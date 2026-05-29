import Actuate
import SwiftUI

struct AddCommentExampleView: View {
    let issue: Issue

    @State private var bodyText = ""

    private var addComment: AsyncAction<AddCommentInput, IssueDetail>

    init(issue: Issue, issueRepository: any IssueRepository) {
        self.issue = issue
        self.addComment = AsyncAction { input in
            try await issueRepository.addComment(input)
        }
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
                    await addComment.run(addCommentInput)
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        AddCommentExampleView(
            issue: Issue(id: 1, title: "Fix login timeout", status: .open),
            issueRepository: PreviewIssueRepository()
        )
    }
}
