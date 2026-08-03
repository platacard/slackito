import Foundation
import Testing
@testable import Slackito

@Suite("OmittedBlockTests")
@MainActor
struct OmittedBlockTests {

    private func blocks(of message: SlackMessage) throws -> [[String: Any]] {
        let object = try JSONSerialization.jsonObject(with: Data(message.json.utf8)) as? [String: Any]
        return (object?["blocks"] as? [[String: Any]]) ?? []
    }

    @Test
    func aBlockWithEmptyRequiredTextIsOmittedInsteadOfBeingRejectedBySlack() throws {
        let message = SlackMessage(channel: "C1", text: "fallback") {
            Header("")
            MarkdownSection("")
            PlainSection("")
            Header("kept")
        }

        let blocks = try blocks(of: message)

        #expect(blocks.count == 1)
        #expect((blocks[0]["text"] as? [String: Any])?["text"] as? String == "kept")
    }

    @Test
    func containersWithNoElementsAreOmitted() throws {
        let message = SlackMessage(channel: "C1", text: "fallback") {
            Actions([])
            FieldsSection { }
            Context { }
            Image(url: "", text: "alt")
            Divider()
        }

        let blocks = try blocks(of: message)

        #expect(blocks.count == 1)
        #expect(blocks[0]["type"] as? String == "divider")
    }

    @Test
    func anImageAccessoryWithoutAUrlIsOmitted() throws {
        let section = MarkdownSection("text", accessory: .image(ImageAccessory(url: "", text: "alt")))

        let object = try JSONSerialization.jsonObject(with: Data(section.json.utf8)) as? [String: Any]

        #expect(object?["accessory"] == nil)
    }

    @Test
    func aTextOnlyMessageIsAllowedBecauseSlackAllowsIt() throws {
        let message = SlackMessage(channel: "C1", text: "deploy finished", blocks: [])

        let object = try JSONSerialization.jsonObject(with: Data(message.json.utf8)) as? [String: Any]

        #expect(throws: Never.self) { try message.validate() }
        #expect(object?["text"] as? String == "deploy finished")
        #expect(object?["blocks"] == nil)
    }

    @Test
    func aMessageWithNothingToSayStillFailsValidation() throws {
        let message = SlackMessage(channel: "C1", blocks: [Header(""), Actions([])])

        #expect(throws: SlackMessageError.emptyMessage) { try message.validate() }
    }

    @Test
    func omittedBlocksDoNotCountTowardsTheBlockLimit() throws {
        let padding: [BlockConvertible] = (1...50).map { _ in Divider() }
        let message = SlackMessage(channel: "C1", blocks: padding + [Header(""), Actions([])])

        #expect(throws: Never.self) { try message.validate() }
    }
}
