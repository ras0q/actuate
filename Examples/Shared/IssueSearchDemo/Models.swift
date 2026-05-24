import Foundation

enum IssueStatus: String, CaseIterable, Sendable {
    case open
    case closed

    var label: String {
        switch self {
        case .open: "Open"
        case .closed: "Closed"
        }
    }
}

enum IssueSort: String, CaseIterable, Sendable {
    case recentlyUpdated
    case created

    var label: String {
        switch self {
        case .recentlyUpdated: "Recently updated"
        case .created: "Created"
        }
    }
}

struct Issue: Identifiable, Sendable, Equatable {
    let id: Int
    let title: String
    let status: IssueStatus
}

struct SearchIssuesInput: Sendable, Equatable {
    var keyword: String
    var status: IssueStatus?
    var sort: IssueSort
    var page: Int
    var pageSize: Int
}

struct LoadIssueDetailInput: Sendable, Equatable {
    let issueID: Int
}

struct IssueDetail: Sendable, Equatable {
    let issue: Issue
    let body: String
}

struct AddCommentInput: Sendable, Equatable {
    let issueID: Int
    let body: String
}

struct SearchError: Error, Sendable {
    let message: String
}
