import ActuateCore
import SwiftUI

struct SearchIssuesScreen: View {
    @Binding var keyword: String
    @Binding var status: IssueStatus?
    @Binding var sort: IssueSort
    let phase: AsyncPhase<[Issue]>
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            SearchIssuesForm(keyword: $keyword, status: $status, sort: $sort)
            SearchIssuesResults(phase: phase, onRetry: onRetry)
            Spacer()
        }
        .padding()
        .navigationTitle("Search Issues")
    }
}

struct SearchIssuesForm: View {
    @Binding var keyword: String
    @Binding var status: IssueStatus?
    @Binding var sort: IssueSort

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Keyword (try \"fail\" to simulate error)", text: $keyword)
                .textFieldStyle(.roundedBorder)

            Picker("Status", selection: $status) {
                Text("All").tag(IssueStatus?.none)
                ForEach(IssueStatus.allCases, id: \.self) { status in
                    Text(status.label).tag(Optional(status))
                }
            }

            Picker("Sort", selection: $sort) {
                ForEach(IssueSort.allCases, id: \.self) { sort in
                    Text(sort.label).tag(sort)
                }
            }
        }
    }
}

struct SearchIssuesResults: View {
    let phase: AsyncPhase<[Issue]>
    let onRetry: () -> Void

    var body: some View {
        switch phase {
        case .idle:
            ContentUnavailableView(
                "Search issues",
                systemImage: "magnifyingglass",
                description: Text("Enter a keyword to search mock issues.")
            )

        case .loading(let previous):
            if let previous {
                IssueListSection(issues: previous, title: "Previous results")
            } else {
                ProgressView("Searching…")
            }

        case .success(let issues):
            IssueListSection(issues: issues, title: "Results")

        case .failure(let error, let previous):
            VStack(spacing: 12) {
                if let previous {
                    IssueListSection(issues: previous, title: "Previous results")
                }
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                Button("Retry", action: onRetry)
            }
        }
    }
}

struct AddCommentScreen: View {
    let issue: Issue
    @Binding var bodyText: String
    let phase: AsyncPhase<IssueDetail>
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(issue.title)
                .font(.title2)

            TextField("Comment", text: $bodyText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)

            Button("Submit", action: onSubmit)
                .disabled(phase.isLoading || bodyText.isEmpty)

            AddCommentResults(phase: phase)

            Spacer()
        }
        .padding()
        .navigationTitle("Add Comment")
    }
}

struct AddCommentResults: View {
    let phase: AsyncPhase<IssueDetail>

    var body: some View {
        switch phase {
        case .idle:
            EmptyView()

        case .loading:
            ProgressView("Submitting…")

        case .success(let detail):
            Label(detail.body, systemImage: "checkmark.circle")
                .foregroundStyle(.green)

        case .failure(let error, _):
            Text(error.localizedDescription)
                .foregroundStyle(.red)
        }
    }
}

struct IssueListSection: View {
    let issues: [Issue]
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.heading)
            List(issues) { issue in
                HStack {
                    Text("#\(issue.id)")
                        .foregroundStyle(.secondary)
                    Text(issue.title)
                    Spacer()
                    Text(issue.status.label)
                        .font(.caption)
                        .foregroundStyle(issue.status == .open ? .green : .secondary)
                }
            }
            .listStyle(.plain)
        }
    }
}

extension Font {
    static var heading: Font { .headline }
}
