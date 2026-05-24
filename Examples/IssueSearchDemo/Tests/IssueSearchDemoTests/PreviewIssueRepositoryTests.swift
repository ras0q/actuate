import Foundation
import Testing

@testable import IssueSearchDemo

@Suite("PreviewIssueRepository")
struct PreviewIssueRepositoryTests {
    private let repository = PreviewIssueRepository()

    private func searchInput(
        keyword: String = "",
        status: IssueStatus? = nil,
        sort: IssueSort = .recentlyUpdated,
        pageSize: Int = 20
    ) -> SearchIssuesInput {
        SearchIssuesInput(
            keyword: keyword,
            status: status,
            sort: sort,
            page: 1,
            pageSize: pageSize
        )
    }

    @Test("empty keyword returns all issues sorted by recently updated")
    func searchAllRecentlyUpdated() async throws {
        let issues = try await repository.searchIssues(searchInput())
        #expect(issues.map(\.id) == [5, 4, 3, 2, 1])
    }

    @Test("keyword filters titles")
    func searchKeyword() async throws {
        let issues = try await repository.searchIssues(searchInput(keyword: "login"))
        #expect(issues.map(\.id) == [1])
    }

    @Test("status filter keeps matching issues")
    func searchStatus() async throws {
        let issues = try await repository.searchIssues(searchInput(status: .open))
        #expect(issues.map(\.id) == [4, 2, 1])
    }

    @Test("created sort orders by ascending id")
    func searchCreatedSort() async throws {
        let issues = try await repository.searchIssues(searchInput(sort: .created))
        #expect(issues.map(\.id) == [1, 2, 3, 4, 5])
    }

    @Test("page size limits results")
    func searchPageSize() async throws {
        let issues = try await repository.searchIssues(searchInput(pageSize: 2))
        #expect(issues.count == 2)
        #expect(issues.map(\.id) == [5, 4])
    }

    @Test("fail keyword throws SearchError")
    func searchFailure() async {
        do {
            _ = try await repository.searchIssues(searchInput(keyword: "fail"))
            Testing.Issue.record("Expected SearchError")
        } catch let error as SearchError {
            #expect(error.message == "Simulated network failure")
        } catch {
            Testing.Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("loadIssueDetail returns detail for known issue")
    func loadDetail() async throws {
        let detail = try await repository.loadIssueDetail(LoadIssueDetailInput(issueID: 1))
        #expect(detail.issue.id == 1)
        #expect(detail.body == "Detail for #1: Fix login timeout")
    }

    @Test("loadIssueDetail throws for unknown issue")
    func loadDetailNotFound() async {
        do {
            _ = try await repository.loadIssueDetail(LoadIssueDetailInput(issueID: 999))
            Testing.Issue.record("Expected SearchError")
        } catch let error as SearchError {
            #expect(error.message == "Issue not found")
        } catch {
            Testing.Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("addComment returns updated detail")
    func addComment() async throws {
        let detail = try await repository.addComment(
            AddCommentInput(issueID: 2, body: "Looks good")
        )
        #expect(detail.issue.id == 2)
        #expect(detail.body == "Updated with comment: Looks good")
    }
}
