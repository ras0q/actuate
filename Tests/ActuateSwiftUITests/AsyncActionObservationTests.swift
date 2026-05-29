import ActuateSwiftUI
import SwiftUI
import Testing

@Suite("AsyncAction Observation")
@MainActor
struct AsyncActionObservationTests {
    @Test("AsyncAction phase reads backing state")
    func phaseObservation() async {
        let action = AsyncAction { (_: String) in 7 }
        #expect(action.phase.isIdle)
        await action.run("x")
        #expect(action.phase.output == 7)
    }
}
