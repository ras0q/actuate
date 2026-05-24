public enum AsyncPhase<Output: Sendable>: Sendable {
    case idle
    case loading(previous: Output?)
    case success(Output)
    case failure(any Error & Sendable, previous: Output?)
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
