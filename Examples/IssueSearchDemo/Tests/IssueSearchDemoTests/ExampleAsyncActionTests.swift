import Foundation
import Actuate
import Testing

@testable import IssueSearchDemo

@Suite("Example AsyncAction wiring")
@MainActor
struct ExampleAsyncActionTests {
    private let repository = PreviewIssueRepository()

    @Test("debounced search resolves to matching issues")
    func debouncedSearch() async {
        let actuator = Actuator<SearchIssuesInput, [IssueSearchDemo.Issue]>()
        let input = SearchIssuesInput(
            keyword: "dark",
            status: nil,
            sort: .recentlyUpdated,
            page: 1,
            pageSize: 20
        )

        await actuator.run(
            input: input,
            policy: AsyncActionPolicy.debounced(for: .milliseconds(50))
        ) { input in
            try await repository.searchIssues(input)
        }

        #expect(actuator.phase.output?.map(\.id) == [2])
    }

    @Test("search failure becomes failure phase with previous results")
    func searchFailureKeepsPrevious() async {
        let actuator = Actuator<SearchIssuesInput, [IssueSearchDemo.Issue]>()
        let successInput = SearchIssuesInput(
            keyword: "dark",
            status: nil,
            sort: .recentlyUpdated,
            page: 1,
            pageSize: 20
        )
        let failureInput = SearchIssuesInput(
            keyword: "fail",
            status: nil,
            sort: .recentlyUpdated,
            page: 1,
            pageSize: 20
        )

        await actuator.run(input: successInput, policy: .refresh) { input in
            try await repository.searchIssues(input)
        }
        await actuator.run(input: failureInput, policy: .refresh) { input in
            try await repository.searchIssues(input)
        }

        if case .failure(_, let previous) = actuator.phase {
            #expect(previous?.map(\.id) == [2])
        } else {
            Testing.Issue.record("Expected failure with previous results")
        }
    }

    @Test("add comment with onDemand policy succeeds")
    func addCommentOnDemandPolicy() async {
        let actuator = Actuator<AddCommentInput, IssueDetail>()
        let input = AddCommentInput(issueID: 1, body: "Ship it")

        await actuator.run(input: input, policy: .onDemand) { input in
            try await repository.addComment(input)
        }

        #expect(actuator.phase.output?.body == "Updated with comment: Ship it")
    }
}
