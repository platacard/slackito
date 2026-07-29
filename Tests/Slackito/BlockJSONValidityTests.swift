import Foundation
import Testing
@testable import Slackito

private let dirtyStrings = [
    #"quote " and backslash \"#,
    "crlf \r\n tab \t",
    "ansi \u{1B}[0;31mred\u{1B}[0m",
    "nul \u{0} bell \u{07} formfeed \u{0C}",
    "emoji 💥 ñ 𝕏",
    String(repeating: #"a"b\c"#, count: 50)
]

@Suite("BlockJSONValidityTests")
@MainActor
struct BlockJSONValidityTests {

    @Test(arguments: dirtyStrings)
    func everyBlockStaysValidJSON(dirty: String) throws {
        let blocks: [BlockConvertible] = [
            Divider(),
            Header(dirty),
            MarkdownSection(dirty),
            MarkdownSection(dirty, accessory: .image(ImageAccessory(url: dirty, text: dirty))),
            MarkdownSection(dirty, accessory: .button(Button(dirty, url: dirty))),
            MarkdownSection(dirty, accessory: .overflow(Overflow(actionId: dirty) {
                Overflow.Option(text: dirty, url: dirty, value: dirty)
            })),
            PlainSection(dirty, accessory: .image(ImageAccessory(url: dirty, text: dirty))),
            FieldsSection { dirty; dirty },
            Context { dirty },
            Image(url: dirty, text: dirty),
            Actions([Button(dirty, url: dirty), Button(dirty)])
        ]

        for block in blocks {
            #expect(throws: Never.self) {
                try JSONSerialization.jsonObject(with: Data(block.json.utf8))
            }
        }
    }

    @Test(arguments: dirtyStrings)
    func messagePayloadStaysValidJSON(dirty: String) throws {
        let message = SlackMessage(channel: dirty, ts: dirty) {
            Header(dirty)
            MarkdownSection(dirty)
        }

        #expect(throws: Never.self) {
            try JSONSerialization.jsonObject(with: Data(message.json.utf8))
        }
    }

    @Test
    func escapingRoundTripsThroughJSONDecoding() throws {
        let raw = "error: bad\r\n\u{1B}[1;31mred\u{1B}[0m \u{07}bell\u{0}end \"quoted\" \\ backslash"

        let json = MarkdownSection(raw).json
        let object = try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any]
        let text = (object?["text"] as? [String: Any])?["text"] as? String

        #expect(text == raw)
    }

    @Test
    func newlinesSurviveAsRealLineBreaks() throws {
        let json = MarkdownSection("first\nsecond").json

        #expect(json.contains(#"first\nsecond"#))
    }
}
