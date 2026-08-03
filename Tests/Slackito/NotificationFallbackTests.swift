import Foundation
import Testing
@testable import Slackito

@Suite("NotificationFallbackTests")
@MainActor
struct NotificationFallbackTests {

    private func text(of message: SlackMessage) throws -> String? {
        let object = try JSONSerialization.jsonObject(with: Data(message.json.utf8)) as? [String: Any]
        return object?["text"] as? String
    }

    @Test
    func aMessageWithoutAHeaderStillGetsAFallback() throws {
        let message = SlackMessage(channel: "C1") {
            Divider()
            FieldsSection { "*Passed:* 10" }
            Context { "*Branch*: main" }
        }

        #expect(try text(of: message) == "Passed: 10")
    }

    @Test
    func theFallbackCarriesNoMarkupIntoThePushNotification() throws {
        let message = SlackMessage(channel: "C1") {
            MarkdownSection("*<https://job|Payments>* `failed` in 2 runs")
        }

        #expect(try text(of: message) == "Payments failed in 2 runs")
    }

    @Test
    func aMessageWithNoTextAtAllOmitsTheFallback() throws {
        let message = SlackMessage(channel: "C1") { Divider() }

        #expect(try text(of: message) == nil)
    }

    @Test
    func droppedElementsAreReportedInsteadOfVanishingSilently() throws {
        let message = SlackMessage(channel: "C1") {
            Actions((1...30).map { Button("Button \($0)", url: "https://example.com/\($0)") })
            Context { for index in 1...15 { "element \(index)" } }
            MarkdownSection("t", accessory: .overflow(Overflow(options: (1...9).map {
                Overflow.Option(text: "Option \($0)")
            })))
        }

        let warnings = message.warnings

        #expect(warnings.count == 3)
        #expect(warnings.contains { $0.contains("5 of 30 action buttons") })
        #expect(warnings.contains { $0.contains("5 of 15 context elements") })
        #expect(warnings.contains { $0.contains("4 of 9 overflow options") })
    }

    @Test
    func aMessageWithinEveryLimitReportsNoWarnings() throws {
        let message = SlackMessage(channel: "C1") {
            Header("Run UI tests result")
            Actions([Button("Job", url: "https://job")])
        }

        #expect(message.warnings.isEmpty)
    }
}
