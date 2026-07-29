import Foundation
import Testing
@testable import Slackito

@Suite("ButtonTests")
@MainActor
struct ButtonTests {

    private func element(of button: Button) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: Data(button.json.utf8)) as? [String: Any]
        return try #require(object)
    }

    @Test
    func aPlainLinkButtonCarriesNeitherStyleNorActionId() throws {
        let element = try element(of: Button("Job", url: "https://example.com"))

        #expect(element["type"] as? String == "button")
        #expect(element["url"] as? String == "https://example.com")
        #expect(element["style"] == nil)
        #expect(element["action_id"] == nil)
    }

    @Test(arguments: [Button.Style.primary, .danger])
    func styleIsRenderedWhenAsked(style: Button.Style) throws {
        let element = try element(of: Button("Retry", url: "https://example.com", style: style))

        #expect(element["style"] as? String == style.rawValue)
    }

    @Test
    func actionIdIsRenderedWhenAsked() throws {
        let element = try element(of: Button("Retry", actionId: "retry_run"))

        #expect(element["action_id"] as? String == "retry_run")
        #expect(element["url"] == nil)
    }

    @Test
    func anEmptyUrlIsOmittedRatherThanSentAsAnEmptyString() throws {
        let element = try element(of: Button("Retry", url: ""))

        #expect(element["url"] == nil)
    }

    @Test
    func aButtonAccessoryRendersTheSameElementAsAButton() throws {
        let section = MarkdownSection("text", accessory: .button(Button("Launch", url: "https://example.com")))

        let object = try JSONSerialization.jsonObject(with: Data(section.json.utf8)) as? [String: Any]
        let accessory = try #require(object?["accessory"] as? [String: Any])
        let standalone = try element(of: Button("Launch", url: "https://example.com"))

        #expect(accessory as NSDictionary == standalone as NSDictionary)
    }
}
