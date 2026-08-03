import Foundation
import Testing
@testable import Slackito

@Suite("BlockSnapshotTests")
@MainActor
struct BlockSnapshotTests {

    private func expect(_ block: BlockConvertible, rendersAs expected: String) throws {
        let actual = try #require(JSONSerialization.jsonObject(with: Data(block.json.utf8)) as? NSDictionary)
        let wanted = try #require(JSONSerialization.jsonObject(with: Data(expected.utf8)) as? NSDictionary)

        #expect(actual == wanted)
    }

    @Test
    func divider() throws {
        try expect(Divider(), rendersAs: #"{ "type": "divider" }"#)
    }

    @Test
    func header() throws {
        try expect(Header("Run UI tests result"), rendersAs: """
        { "type": "header", "text": { "type": "plain_text", "text": "Run UI tests result" } }
        """)
    }

    @Test
    func markdownSection() throws {
        try expect(MarkdownSection("*Passed:* 10"), rendersAs: """
        { "type": "section", "text": { "type": "mrkdwn", "text": "*Passed:* 10" } }
        """)
    }

    @Test
    func markdownSectionWithImageAccessory() throws {
        let block = MarkdownSection("avatar", accessory: .image(ImageAccessory(url: "https://img", text: "alt")))

        try expect(block, rendersAs: """
        { "type": "section", "text": { "type": "mrkdwn", "text": "avatar" },
          "accessory": { "type": "image", "image_url": "https://img", "alt_text": "alt" } }
        """)
    }

    @Test
    func markdownSectionWithButtonAccessory() throws {
        let block = MarkdownSection("build", accessory: .button(Button("Job", url: "https://job")))

        try expect(block, rendersAs: """
        { "type": "section", "text": { "type": "mrkdwn", "text": "build" },
          "accessory": { "type": "button", "text": { "type": "plain_text", "text": "Job", "emoji": true },
          "url": "https://job" } }
        """)
    }

    @Test
    func markdownSectionWithOverflowAccessory() throws {
        let block = MarkdownSection("build", accessory: .overflow(Overflow(actionId: "links") {
            Overflow.Option(text: "Job", url: "https://job")
        }))

        try expect(block, rendersAs: """
        { "type": "section", "text": { "type": "mrkdwn", "text": "build" },
          "accessory": { "type": "overflow", "action_id": "links", "options": [
            { "text": { "type": "plain_text", "emoji": true, "text": "Job" },
              "value": "option_0", "url": "https://job" }
          ] } }
        """)
    }

    @Test
    func plainSection() throws {
        try expect(PlainSection("plain"), rendersAs: """
        { "type": "section", "text": { "type": "plain_text", "text": "plain" } }
        """)
    }

    @Test
    func fieldsSection() throws {
        try expect(FieldsSection { "left"; "right" }, rendersAs: """
        { "type": "section", "fields": [
          { "type": "mrkdwn", "text": "left" }, { "type": "mrkdwn", "text": "right" }
        ] }
        """)
    }

    @Test
    func context() throws {
        try expect(Context { "*Branch*: main" }, rendersAs: """
        { "type": "context", "elements": [ { "type": "mrkdwn", "text": "*Branch*: main" } ] }
        """)
    }

    @Test
    func image() throws {
        try expect(Image(url: "https://img", text: "alt"), rendersAs: """
        { "type": "image", "title": { "type": "plain_text", "text": "alt", "emoji": true },
          "image_url": "https://img", "alt_text": "alt" }
        """)
    }

    @Test
    func actions() throws {
        let block = Actions {
            Button("Job", url: "https://job")
            Button("Retry", style: .danger, actionId: "retry")
        }

        try expect(block, rendersAs: """
        { "type": "actions", "elements": [
          { "type": "button", "text": { "type": "plain_text", "text": "Job", "emoji": true }, "url": "https://job" },
          { "type": "button", "text": { "type": "plain_text", "text": "Retry", "emoji": true },
            "style": "danger", "action_id": "retry" }
        ] }
        """)
    }
}
