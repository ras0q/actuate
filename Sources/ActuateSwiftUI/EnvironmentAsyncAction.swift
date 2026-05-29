import ActuateCore
import SwiftUI

@MainActor
public struct EnvironmentAsyncAction<Dependency: Sendable, Input: Sendable, Output: Sendable>:
    DynamicProperty
{
    public typealias Operation =
        @Sendable (Dependency, Input) async throws(any Error & Sendable) -> Output

    @SwiftUI.Environment private var dependency: Dependency
    @State private var actuator = Actuator<Input, Output>()

    private let policy: AsyncActionPolicy<Input>
    private let operation: Operation

    public init(
        _ keyPath: KeyPath<EnvironmentValues, Dependency>,
        policy: AsyncActionPolicy<Input> = .onDemand,
        operation: @escaping Operation
    ) {
        self._dependency = SwiftUI.Environment(keyPath)
        self.policy = policy
        self.operation = operation
    }

    public var phase: AsyncPhase<Output> {
        actuator.phase
    }

    public func run(_ input: Input, force: Bool = false) async {
        await actuator.run(
            input,
            force: force,
            policy: policy,
            operation: { input in
                try await operation(dependency, input)
            }
        )
    }

    public func cancel() {
        actuator.cancel()
    }

    public func reset() {
        actuator.reset()
    }
}
