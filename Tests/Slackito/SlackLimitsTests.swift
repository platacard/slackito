import Foundation
import Testing
@testable import Slackito

@Suite("SlackLimitsTests")
@MainActor
struct SlackLimitsTests {

    private func text(of block: BlockConvertible, key: String = "text") throws -> String {
        let object = try JSONSerialization.jsonObject(with: Data(block.json.utf8)) as? [String: Any]
        let nested = try #require(object?[key] as? [String: Any])
        return try #require(nested["text"] as? String)
    }

    @Test
    func headerTextIsTruncatedToTheSlackLimit() throws {
        let rendered = try text(of: Header(String(repeating: "a", count: 400)))

        #expect(rendered.count == SlackLimits.headerText)
        #expect(rendered.hasSuffix("…"))
    }

    @Test
    func sectionTextIsTruncatedToTheSlackLimit() throws {
        let rendered = try text(of: MarkdownSection(String(repeating: "a", count: 5000)))

        #expect(rendered.count == SlackLimits.sectionText)
    }

    @Test
    func buttonTextIsTruncatedToTheSlackLimit() throws {
        let json = Actions([Button(String(repeating: "a", count: 200), url: "https://example.com")]).json
        let object = try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any]
        let elements = try #require(object?["elements"] as? [[String: Any]])
        let rendered = try #require((elements[0]["text"] as? [String: Any])?["text"] as? String)

        #expect(rendered.count == SlackLimits.buttonText)
    }

    @Test
    func extraOverflowOptionsAreDroppedInsteadOfBeingRejected() throws {
        let options = (1...9).map { Overflow.Option(text: "Option \($0)", url: "https://example.com/\($0)") }
        let section = MarkdownSection("text", accessory: .overflow(Overflow(options: options)))

        let object = try JSONSerialization.jsonObject(with: Data(section.json.utf8)) as? [String: Any]
        let accessory = try #require(object?["accessory"] as? [String: Any])

        #expect((accessory["options"] as? [[String: Any]])?.count == SlackLimits.optionsPerOverflow)
    }

    @Test
    func extraActionElementsAndFieldsAreDropped() throws {
        let actions = Actions((1...30).map { Button("Button \($0)", url: "https://example.com/\($0)") })
        let fields = FieldsSection { for index in 1...15 { MarkdownSection("field \(index)") } }

        let actionsObject = try JSONSerialization.jsonObject(with: Data(actions.json.utf8)) as? [String: Any]
        let fieldsObject = try JSONSerialization.jsonObject(with: Data(fields.json.utf8)) as? [String: Any]

        #expect((actionsObject?["elements"] as? [[String: Any]])?.count == SlackLimits.elementsPerActions)
        #expect((fieldsObject?["fields"] as? [[String: Any]])?.count == SlackLimits.fieldsPerSection)
    }

    @Test
    func aMessageOverTheBlockLimitFailsValidationInsteadOfSlackRejectingIt() throws {
        let message = SlackMessage(channel: "C1", blocks: (1...60).map { _ in Divider() })

        #expect(throws: SlackMessageError.tooManyBlocks(count: 60, limit: SlackLimits.blocksPerMessage)) {
            try message.validate()
        }
    }

    @Test
    func aMessageWithinTheBlockLimitPassesValidation() throws {
        let message = SlackMessage(channel: "C1", blocks: (1...50).map { _ in Divider() })

        #expect(throws: Never.self) { try message.validate() }
    }

    @Test
    func anEmptyMessageFailsValidation() throws {
        let message = SlackMessage(channel: "C1", blocks: [])

        #expect(throws: SlackMessageError.emptyMessage) { try message.validate() }
    }
}
