import Observation

@MainActor
@Observable
public final class Actuator<Input: Sendable, Output: Sendable> {
    public private(set) var phase: AsyncPhase<Output> = .idle

    private var task: Task<Output, any Error & Sendable>?
    private var generation: UInt64 = 0
    private var lastStartedInput: Input?
    private var lastSuccessOutput: Output?

    public init() {}

    public func run(
        _ input: Input,
        force: Bool = false,
        policy: AsyncActionPolicy<Input>,
        operation: @escaping @Sendable (Input) async throws(any Error & Sendable) -> Output
    ) async {
        if !force,
            let removesDuplicates = policy.removesDuplicates,
            let lastStartedInput,
            removesDuplicates(lastStartedInput, input)
        {
            return
        }

        task?.cancel()
        task = nil

        generation &+= 1
        let token = generation

        if let debounce = policy.debounce {
            do {
                try await Task.sleep(for: debounce)
            } catch {
                if token == generation {
                    performCallerCancellationCleanup(token: token)
                }
                return
            }

            guard !Task.isCancelled else {
                if token == generation {
                    performCallerCancellationCleanup(token: token)
                }
                return
            }

            guard token == generation else {
                return
            }
        }

        let previousForPolicy = policy.keepsPreviousResult ? lastSuccessOutput : nil
        lastStartedInput = input
        phase = .loading(previous: previousForPolicy)

        let managedTask = Task {
            try await operation(input)
        }
        task = managedTask

        do {
            try await withTaskCancellationHandler {
                let output = try await managedTask.value
                guard token == generation else { return }
                guard !managedTask.isCancelled else { return }
                try Task.checkCancellation()

                lastSuccessOutput = output
                phase = .success(output)
                if token == generation {
                    task = nil
                }
            } onCancel: {
                managedTask.cancel()
            }
        } catch is CancellationError {
            if token == generation {
                performCallerCancellationCleanup(token: token)
            }
        } catch {
            guard token == generation else { return }
            guard !managedTask.isCancelled else { return }
            try? Task.checkCancellation()

            let previousForFailure = policy.keepsPreviousResult ? lastSuccessOutput : nil
            phase = .failure(error, previous: previousForFailure)
            if token == generation {
                task = nil
            }
        }
    }

    public func cancel() {
        generation &+= 1
        task?.cancel()
        task = nil
        lastStartedInput = nil

        if let lastSuccessOutput {
            phase = .success(lastSuccessOutput)
        } else {
            phase = .idle
        }
    }

    public func reset() {
        generation &+= 1
        task?.cancel()
        task = nil
        phase = .idle
        lastSuccessOutput = nil
        lastStartedInput = nil
    }

    private func performCallerCancellationCleanup(token: UInt64) {
        guard token == generation else { return }

        generation &+= 1
        task?.cancel()
        task = nil
        lastStartedInput = nil

        if let lastSuccessOutput {
            phase = .success(lastSuccessOutput)
        } else {
            phase = .idle
        }
    }
}
