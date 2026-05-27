public enum AsyncPhase<Output: Sendable>: Sendable {
    case idle
    case loading(previous: Output?)
    case success(Output)
    case failure(any Error & Sendable, previous: Output?)
}

extension AsyncPhase: Equatable where Output: Equatable {
    public static func == (lhs: AsyncPhase<Output>, rhs: AsyncPhase<Output>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading(let lhsPrevious), .loading(let rhsPrevious)):
            return lhsPrevious == rhsPrevious
        case (.success(let lhsOutput), .success(let rhsOutput)):
            return lhsOutput == rhsOutput
        case (.failure(let lhsError, let lhsPrevious), .failure(let rhsError, let rhsPrevious)):
            return lhsPrevious == rhsPrevious && isEquivalent(lhsError, rhsError)
        default:
            return false
        }
    }

    private static func isEquivalent(
        _ lhs: any Error & Sendable,
        _ rhs: any Error & Sendable
    ) -> Bool {
        type(of: lhs) == type(of: rhs) && String(describing: lhs) == String(describing: rhs)
    }
}

extension AsyncPhase {
    public var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    public var output: Output? {
        if case .success(let output) = self { return output }
        return nil
    }

    public var previous: Output? {
        switch self {
        case .loading(let previous), .failure(_, let previous):
            return previous
        case .idle, .success:
            return nil
        }
    }

    public var error: (any Error & Sendable)? {
        if case .failure(let error, _) = self { return error }
        return nil
    }
}
