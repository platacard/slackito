import Foundation
import Testing
@testable import Slackito

@Suite("SlackMessagePayloadTests")
@MainActor
struct SlackMessagePayloadTests {

    private func payload(of message: SlackMessage) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: Data(message.json.utf8)) as? [String: Any]
        return try #require(object)
    }

    @Test
    func explicitTextIsSentAsTheNotificationFallback() throws {
        let message = SlackMessage(channel: "C1", text: "UI tests finished") {
            Header("Run UI tests result")
        }

        #expect(try payload(of: message)["text"] as? String == "UI tests finished")
    }

    @Test
    func fallbackTextIsDerivedFromTheFirstTextBlock() throws {
        let message = SlackMessage(channel: "C1") {
            Divider()
            Header("Run UI tests result")
            MarkdownSection("*Passed:* 10")
        }

        #expect(try payload(of: message)["text"] as? String == "Run UI tests result")
    }

    @Test
    func updateSendsTsWithoutTurningTheMessageIntoAReply() throws {
        let message = SlackMessage(channel: "C1", ts: "1785317000.244939") {
            Header("Run UI tests result")
        }

        let payload = try payload(of: message)

        #expect(payload["ts"] as? String == "1785317000.244939")
        #expect(payload["thread_ts"] == nil)
    }

    @Test
    func replySendsThreadTsOnly() throws {
        let message = SlackMessage(channel: "C1", threadTs: "1785317000.244939") {
            MarkdownSection("see above")
        }

        let payload = try payload(of: message)

        #expect(payload["thread_ts"] as? String == "1785317000.244939")
        #expect(payload["ts"] == nil)
    }

    @Test
    func aMessageWithoutTextBlocksOmitsTheFallback() throws {
        let message = SlackMessage(channel: "C1") { Divider() }

        #expect(try payload(of: message)["text"] == nil)
    }
}
