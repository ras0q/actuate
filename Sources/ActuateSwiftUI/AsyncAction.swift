import ActuateCore
import SwiftUI

@MainActor
public struct AsyncAction<Input: Sendable, Output: Sendable>: DynamicProperty {
    @State private var actuator = Actuator<Input, Output>()

    private let policy: AsyncActionPolicy<Input>
    private let operation: @Sendable (Input) async throws(any Error & Sendable) -> Output

    public init(
        policy: AsyncActionPolicy<Input> = .onDemand,
        operation: @escaping @Sendable (Input) async throws(any Error & Sendable) -> Output
    ) {
        self.policy = policy
        self.operation = operation
    }

    public var phase: AsyncPhase<Output> {
        actuator.phase
    }

    public func run(input: Input, force: Bool = false) async {
        await actuator.run(input: input, force: force, policy: policy, operation: operation)
    }

    public func cancel() {
        actuator.cancel()
    }

    public func reset() {
        actuator.reset()
    }
}
