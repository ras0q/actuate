public struct AsyncActionPolicy<Input: Sendable>: Sendable {
    internal let debounce: Duration?
    internal let removesDuplicates: (@Sendable (Input, Input) -> Bool)?
    internal let keepsPreviousResult: Bool

    public static var onDemand: Self {
        Self(debounce: nil, removesDuplicates: nil, keepsPreviousResult: false)
    }

    public static var refresh: Self {
        Self(debounce: nil, removesDuplicates: nil, keepsPreviousResult: true)
    }

    public static func custom(
        debounce: Duration? = nil,
        removesDuplicates: (@Sendable (Input, Input) -> Bool)? = nil,
        keepsPreviousResult: Bool = true
    ) -> Self {
        Self(
            debounce: debounce,
            removesDuplicates: removesDuplicates,
            keepsPreviousResult: keepsPreviousResult
        )
    }
}

extension AsyncActionPolicy where Input: Equatable {
    public static func debounced(for duration: Duration = .milliseconds(300)) -> Self {
        Self(
            debounce: duration,
            removesDuplicates: { $0 == $1 },
            keepsPreviousResult: true
        )
    }
}
