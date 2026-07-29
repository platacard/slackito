import Foundation
import Testing
@testable import Slackito

@Suite("SourceCompatibilityTests")
@MainActor
struct SourceCompatibilityTests {

    @available(*, deprecated)
    @Test
    func everyShapeThatCompiledAgainstTheOldApiStillCompiles() throws {
        let image = ImageAccessory(url: "https://img", text: "alt")
        let button = ButtonAccessory(url: "https://job", text: "Job")

        let sections: [BlockConvertible] = [
            MarkdownSection("x"),
            MarkdownSection("x", imageAccessory: image),
            MarkdownSection("x", imageAccessory: nil),
            MarkdownSection("x", buttonAccessory: button),
            MarkdownSection("x", imageAccessory: image, buttonAccessory: button),
            PlainSection("x"),
            PlainSection("x", accessory: nil),
            PlainSection("x", accessory: image),
            PlainSection("x", imageAccessory: image)
        ]

        #expect(sections.allSatisfy { !$0.json.isEmpty })
    }

    @available(*, deprecated)
    @Test
    func theRemovedAccessoryPropertiesStillRead() throws {
        let image = MarkdownSection("x", accessory: .image(ImageAccessory(url: "https://img", text: "alt")))
        let button = MarkdownSection("x", accessory: .button(Button("Job", url: "https://job")))

        #expect(image.imageAccessory?.url == "https://img")
        #expect(image.buttonAccessory == nil)
        #expect(button.buttonAccessory?.text == "Job")
        #expect(PlainSection("x", accessory: .image(ImageAccessory(url: "u", text: "t"))).imageAccessory?.url == "u")
    }

    @Test
    func aConsumerCanRenderAnAccessoryForItsOwnBlockType() throws {
        let overflow = Overflow(actionId: "links") {
            Overflow.Option(text: "Job", url: "https://job")
        }

        let element = try #require(overflow.element)
        let accessory = try #require(Accessory.overflow(overflow).json)

        #expect(element.contains(#""type": "overflow""#))
        #expect(accessory.hasPrefix(#""accessory": "#))
    }
}
