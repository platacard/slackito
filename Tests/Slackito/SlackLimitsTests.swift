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

    @Test
    func truncationBudgetsCodeUnitsNotGraphemeClusters() throws {
        let family = "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}"

        let rendered = try text(of: Header(String(repeating: family, count: 200)))

        #expect(rendered.unicodeScalars.count <= SlackLimits.headerText)
        #expect(rendered.hasSuffix("…"))
    }

    @Test
    func truncationNeverSplitsAGraphemeCluster() {
        let family = "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}"

        let truncated = String(repeating: family, count: 10).truncated(to: 20)

        #expect(truncated.dropLast().allSatisfy { String($0) == family })
    }

    @Test
    func optionValueUsesTheDocumentedLimitAndIsNotHalved() throws {
        let value = String(repeating: "v", count: 140)
        let section = MarkdownSection("t", accessory: .overflow(Overflow(options: [
            Overflow.Option(text: "Job", value: value)
        ])))

        let object = try JSONSerialization.jsonObject(with: Data(section.json.utf8)) as? [String: Any]
        let accessory = try #require(object?["accessory"] as? [String: Any])
        let options = try #require(accessory["options"] as? [[String: Any]])

        #expect(SlackLimits.optionValue == 150)
        #expect(options[0]["value"] as? String == value)
    }

    @Test
    func imageIsTruncatedLikeEveryOtherBlock() throws {
        let block = Image(url: "https://example.com/" + String(repeating: "u", count: 4000),
                          text: String(repeating: "a", count: 5000))

        let object = try JSONSerialization.jsonObject(with: Data(block.json.utf8)) as? [String: Any]
        let alt = try #require(object?["alt_text"] as? String)
        let source = try #require(object?["image_url"] as? String)
        let title = try #require((object?["title"] as? [String: Any])?["text"] as? String)

        #expect(alt.count == SlackLimits.imageAltText)
        #expect(title.count == SlackLimits.imageTitle)
        #expect(source.count == SlackLimits.url)
    }

    @Test
    func buttonUrlAndActionIdAreCapped() throws {
        let button = Button("Retry",
                            url: "https://example.com/" + String(repeating: "u", count: 4000),
                            actionId: String(repeating: "i", count: 400))

        let object = try JSONSerialization.jsonObject(with: Data(button.json.utf8)) as? [String: Any]

        #expect((object?["url"] as? String)?.count == SlackLimits.url)
        #expect((object?["action_id"] as? String)?.count == SlackLimits.actionId)
    }

    @Test
    func aNonPositiveLimitDoesNotTrap() {
        #expect("abcd".truncated(to: 0) == "")
        #expect("abcd".truncated(to: -5) == "")
    }
}
