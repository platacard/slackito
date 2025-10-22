@testable import Slackito
import Foundation
import Testing

@MainActor
@Suite("Slackito Tests", .disabled(if: true))
struct SlackitoIntegrationTests {

    @Test("test_api_freely")
    func api() async throws {
        let env = ProcessInfo.processInfo.environment
        let channel = env["SLACK_CHANNEL"]!
        let token = env["SLACK_TOKEN"]!

        let csvData = """
        name,age,city
        John,30,New York
        Jane,25,San Francisco
        Bob,35,Chicago
        """.data(using: .utf8)!

        let initialMessage = SlackMessage(channel: channel) {
            PlainSection("Initial message test")
        }

        let result = try await initialMessage.send(as: token)

        let csvAttachment = SlackAttachment(type: .fileData(data: csvData, filename: "test.csv"))

        let message = SlackMessage(
            channel: channel,
            ts: result.timestamp,
            attachments: [csvAttachment]
        ) {
            MarkdownSection("🧪 Testing cleaned up implementation!")
            Context {
                "*Method*: files.getUploadURLExternal + files.completeUploadExternal"
                "*Timestamp*: \(Date())"
            }
        }

        let imageURL = "https://s3-media2.fl.yelpcdn.com/bphoto/DawwNigKJ2ckPeDeDM7jAg/o.jpg"

        let imageMessage = SlackMessage(channel: channel, ts: result.timestamp) {
            MarkdownSection(
                "Wow, an accessory image like avatars",
                accessory: ImageAccessory(
                    url: imageURL,
                    text: "some text"
                )
            )

            MarkdownSection("Wow there's an image even bigger")

            Image(url: imageURL, text: "Wow ima image")
        }

        do {
            let result = try await message.send(as: token)
            let result2 = try await imageMessage.send(as: token)

            print(result)
            print(result2)
        } catch {
            print("❌ Upload failed: \(error.localizedDescription)")
        }
    }
}
