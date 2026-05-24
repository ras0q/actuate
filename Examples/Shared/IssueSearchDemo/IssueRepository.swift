import Foundation
import SwiftUI

protocol IssueRepository: Sendable {
    func searchIssues(_ input: SearchIssuesInput) async throws -> [Issue]
    func loadIssueDetail(_ input: LoadIssueDetailInput) async throws -> IssueDetail
    func addComment(_ input: AddCommentInput) async throws -> IssueDetail
}

private struct IssueRepositoryKey: EnvironmentKey {
    static let defaultValue: any IssueRepository = PreviewIssueRepository()
}

extension EnvironmentValues {
    var issueRepository: any IssueRepository {
        get { self[IssueRepositoryKey.self] }
        set { self[IssueRepositoryKey.self] = newValue }
    }
}

struct PreviewIssueRepository: IssueRepository {
    private let issues: [Issue] = [
        Issue(id: 1, title: "Fix login timeout", status: .open),
        Issue(id: 2, title: "Add dark mode support", status: .open),
        Issue(id: 3, title: "Update README", status: .closed),
        Issue(id: 4, title: "Debounce search input", status: .open),
        Issue(id: 5, title: "Retry failed requests", status: .closed),
    ]

    func searchIssues(_ input: SearchIssuesInput) async throws -> [Issue] {
        try await Task.sleep(for: .milliseconds(400))

        if input.keyword.lowercased() == "fail" {
            throw SearchError(message: "Simulated network failure")
        }

        var results = issues.filter { issue in
            input.keyword.isEmpty
                || issue.title.localizedCaseInsensitiveContains(input.keyword)
        }

        if let status = input.status {
            results = results.filter { $0.status == status }
        }

        switch input.sort {
        case .recentlyUpdated:
            results.sort { $0.id > $1.id }
        case .created:
            results.sort { $0.id < $1.id }
        }

        return Array(results.prefix(input.pageSize))
    }

    func loadIssueDetail(_ input: LoadIssueDetailInput) async throws -> IssueDetail {
        try await Task.sleep(for: .milliseconds(300))
        guard let issue = issues.first(where: { $0.id == input.issueID }) else {
            throw SearchError(message: "Issue not found")
        }
        return IssueDetail(
            issue: issue,
            body: "Detail for #\(issue.id): \(issue.title)"
        )
    }

    func addComment(_ input: AddCommentInput) async throws -> IssueDetail {
        try await Task.sleep(for: .milliseconds(500))
        guard let issue = issues.first(where: { $0.id == input.issueID }) else {
            throw SearchError(message: "Issue not found")
        }
        return IssueDetail(
            issue: issue,
            body: "Updated with comment: \(input.body)"
        )
    }
}
