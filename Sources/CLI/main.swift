#!/usr/bin/env swift

import Foundation
import Slackito

print("🚀 Slackito Sandbox")
print("==================")

let env = ProcessInfo.processInfo.environment
let channel = env["SLACK_CHANNEL"]!
let token = env["SLACK_TOKEN"]!

// Test data
let csvData = """
name,age,city
John,30,New York
Jane,25,San Francisco
Bob,35,Chicago
""".data(using: .utf8)!

print("📊 Test Data Created:")
print("- CSV data: \(csvData.count) bytes")
print()

// Test JSON generation
print("🧪 Testing JSON Generation:")
print("===========================")

// Test CSV attachment with data

let initialMessage = SlackMessage(channel: channel) {
    PlainSection("Initial message test")
}

let result = try await initialMessage.send(as: token)

let csvAttachment = SlackAttachment(type: .fileData(data: csvData, filename: "test.csv"))

// Test message with attachment
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

print("Message JSON:")
print(message.json)
print()

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

print("🚀 Testing Upload:")
print("========================")

do {
    print("Uploading CSV file...")
    let result = try await message.send(as: token)
    let result2 = try await imageMessage.send(as: token)
    print("✅ Upload successful! Message timestamp: \(result.timestamp ?? "N/A")")
    print(result2)
} catch {
    print("❌ Upload failed: \(error.localizedDescription)")
}


print("🎉 Sandbox completed!")
