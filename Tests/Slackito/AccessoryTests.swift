import Foundation
import Testing
@testable import Slackito

@Suite("AccessoryTests")
@MainActor
struct AccessoryTests {

    private func accessory(of block: BlockConvertible) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: Data(block.json.utf8)) as? [String: Any]
        return try #require(object?["accessory"] as? [String: Any])
    }

    @Test
    func sectionRendersOverflowAccessory() throws {
        let section = MarkdownSection(
            "*Payments*",
            accessory: .overflow(
                Overflow(actionId: "report_links") {
                    Overflow.Option(text: ":gitlab: Job", url: "https://gitlab.example/job/1")
                    Overflow.Option(text: ":allure2: Launch", url: "https://allure.example/launch/2")
                }
            )
        )

        let accessory = try accessory(of: section)
        let options = try #require(accessory["options"] as? [[String: Any]])

        #expect(accessory["type"] as? String == "overflow")
        #expect(accessory["action_id"] as? String == "report_links")
        #expect(options.count == 2)
        #expect(options[0]["url"] as? String == "https://gitlab.example/job/1")
    }

    @Test
    func everyOverflowOptionCarriesTheValueSlackRequires() throws {
        let section = MarkdownSection(
            "*Payments*",
            accessory: .overflow(Overflow(options: [Overflow.Option(text: "Job", url: "https://example.com")]))
        )

        let options = try #require(try accessory(of: section)["options"] as? [[String: Any]])

        #expect(options.allSatisfy { ($0["value"] as? String)?.isEmpty == false })
    }

    @Test
    func explicitOptionValueWins() throws {
        let section = MarkdownSection(
            "*Payments*",
            accessory: .overflow(Overflow(options: [Overflow.Option(text: "Job", value: "job")]))
        )

        let options = try #require(try accessory(of: section)["options"] as? [[String: Any]])

        #expect(options[0]["value"] as? String == "job")
        #expect(options[0]["url"] == nil)
    }

    @Test
    func emptyOverflowIsOmittedInsteadOfProducingAnInvalidBlock() throws {
        let section = MarkdownSection("*Payments*", accessory: .overflow(Overflow(options: [])))

        let object = try JSONSerialization.jsonObject(with: Data(section.json.utf8)) as? [String: Any]

        #expect(object?["accessory"] == nil)
        #expect(object?["type"] as? String == "section")
    }

    @Test
    func sectionRendersButtonAccessoryAsAButtonElement() throws {
        let section = MarkdownSection("*Payments*", accessory: .button(Button("Launch", url: "https://example.com")))

        let accessory = try accessory(of: section)

        #expect(accessory["type"] as? String == "button")
        #expect(accessory["url"] as? String == "https://example.com")
    }

    @Test
    func plainSectionSupportsEveryAccessoryKind() throws {
        let section = PlainSection("Payments", accessory: .image(ImageAccessory(url: "https://img", text: "alt")))

        let accessory = try accessory(of: section)

        #expect(accessory["type"] as? String == "image")
        #expect(accessory["image_url"] as? String == "https://img")
    }

    @Test
    func bothAccessoriesCanNoLongerBeSilentlyDropped() throws {
        let image = MarkdownSection("text", accessory: .image(ImageAccessory(url: "https://img", text: "alt")))
        let button = MarkdownSection("text", accessory: .button(Button("Launch", url: "https://example.com")))

        #expect(try accessory(of: image)["type"] as? String == "image")
        #expect(try accessory(of: button)["type"] as? String == "button")
    }
}
