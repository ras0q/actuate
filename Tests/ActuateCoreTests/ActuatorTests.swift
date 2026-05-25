import ActuateCore
import Foundation
import Testing

private struct TestError: Error, Sendable {
    let message: String
}

@Suite("Actuator")
@MainActor
struct ActuatorTests {
    @Test("run transitions loading to success")
    func runSuccess() async {
        let actuator = Actuator<String, Int>()
        await actuator.run(input: "a", policy: .onDemand) { _ in
            42
        }
        #expect(actuator.phase.output == 42)
        #expect(actuator.phase.output == 42)
    }

    @Test("operation failure becomes failure phase")
    func runFailure() async {
        let actuator = Actuator<String, Int>()
        await actuator.run(input: "a", policy: .onDemand) { _ in
            throw TestError(message: "failed")
        }
        if case .failure(let error, _) = actuator.phase {
            #expect((error as? TestError)?.message == "failed")
        } else {
            Issue.record("Expected failure phase")
        }
    }

    @Test("refresh keeps previous on loading and failure")
    func refreshPrevious() async {
        let actuator = Actuator<Int, Int>()
        await actuator.run(input: 1, policy: .refresh) { _ in 1 }
        async let second: Void = actuator.run(input: 2, policy: .refresh) { _ in
            try await Task.sleep(for: .milliseconds(100))
            return 2
        }
        try? await Task.sleep(for: .milliseconds(20))
        if case .loading(let previous) = actuator.phase {
            #expect(previous == 1)
        } else {
            Issue.record("Expected loading with previous")
        }
        await second
    }

    @Test("onDemand does not keep previous")
    func onDemandNoPrevious() async {
        let actuator = Actuator<Int, Int>()
        await actuator.run(input: 1, policy: .onDemand) { _ in 1 }
        async let second: Void = actuator.run(input: 2, policy: .onDemand) { _ in
            try await Task.sleep(for: .milliseconds(100))
            return 2
        }
        try? await Task.sleep(for: .milliseconds(20))
        if case .loading(let previous) = actuator.phase {
            #expect(previous == nil)
        } else {
            Issue.record("Expected loading without previous")
        }
        await second
    }

    @Test("debounced run waits before loading")
    func debounced() async {
        let actuator = Actuator<Int, Int>()
        let runTask = Task {
            await actuator.run(input: 1, policy: .debounced(for: .milliseconds(100))) { _ in 1 }
        }
        try? await Task.sleep(for: .milliseconds(30))
        #expect(actuator.phase.isIdle)
        await runTask.value
        #expect(actuator.phase.output == 1)
    }

    @Test("latest run wins")
    func latestWins() async {
        let actuator = Actuator<Int, Int>()
        async let first: Void = actuator.run(input: 1, policy: .onDemand) { _ in
            try await Task.sleep(for: .milliseconds(100))
            return 1
        }
        try? await Task.sleep(for: .milliseconds(20))
        await actuator.run(input: 2, policy: .onDemand) { _ in 2 }
        await first
        #expect(actuator.phase.output == 2)
    }

    @Test("duplicate input is ignored")
    func duplicate() async {
        let actuator = Actuator<Int, Int>()
        final class Counter: @unchecked Sendable {
            var value = 0
        }
        let counter = Counter()
        async let first: Void = actuator.run(
            input: 1, policy: .custom(removesDuplicates: { $0 == $1 })
        ) { _ in
            counter.value += 1
            try await Task.sleep(for: .milliseconds(100))
            return 1
        }
        try? await Task.sleep(for: .milliseconds(30))
        await actuator.run(input: 1, policy: .custom(removesDuplicates: { $0 == $1 })) { _ in
            counter.value += 1
            return 2
        }
        await first
        #expect(counter.value == 1)
        #expect(actuator.phase.output == 1)
    }

    @Test("force bypasses duplicate prevention")
    func forceRerun() async {
        let actuator = Actuator<Int, Int>()
        await actuator.run(input: 1, policy: .custom(removesDuplicates: { $0 == $1 })) { _ in 1 }
        await actuator.run(input: 1, force: true, policy: .custom(removesDuplicates: { $0 == $1 }))
        {
            _ in 2
        }
        #expect(actuator.phase.output == 2)
    }

    @Test("cancel restores last success")
    func cancelRestoresSuccess() async {
        let actuator = Actuator<Int, Int>()
        await actuator.run(input: 1, policy: .onDemand) { _ in 1 }
        async let run: Void = actuator.run(input: 2, policy: .onDemand) { _ in
            try await Task.sleep(for: .milliseconds(200))
            return 2
        }
        try? await Task.sleep(for: .milliseconds(30))
        actuator.cancel()
        await run
        #expect(actuator.phase.output == 1)
    }

    @Test("cancel without success goes idle")
    func cancelToIdle() async {
        let actuator = Actuator<Int, Int>()
        async let run: Void = actuator.run(input: 1, policy: .onDemand) { _ in
            try await Task.sleep(for: .milliseconds(200))
            return 1
        }
        try? await Task.sleep(for: .milliseconds(30))
        actuator.cancel()
        await run
        #expect(actuator.phase.isIdle)
    }

    @Test("reset clears phase")
    func reset() async {
        let actuator = Actuator<Int, Int>()
        await actuator.run(input: 1, policy: .onDemand) { _ in 1 }
        actuator.reset()
        #expect(actuator.phase.isIdle)
        #expect(actuator.phase.output == nil)
    }

    @Test("cancelled task does not become failure")
    func cancellationNotFailure() async {
        let actuator = Actuator<Int, Int>()
        async let run: Void = actuator.run(input: 1, policy: .onDemand) { _ in
            try await Task.sleep(for: .milliseconds(200))
            throw TestError(message: "should not appear")
        }
        try? await Task.sleep(for: .milliseconds(30))
        actuator.cancel()
        await run
        #expect(actuator.phase.isIdle)
    }
}
