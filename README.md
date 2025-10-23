# Slackito

A client written with result builders to work with Slack Web API. A small part of the larger iOS deploy infrastructure at Plata.

## Installation

Add the package to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/platacard/slackito.git", from: "1.0.0")
]
```

## Usage

```swift
let meta = try meta(...)

let message = SlackMessage(channel: "some_channed", ts: "thread_timestamp") {
    MarkdownSection(
        ":gitlab-success: \(meta.jobUrl) of *\(meta.appName) (\(bundleId))* has finished successfully!"
    )
    
    if let additionalMessage {
        Divider()
        MarkdownSection(additionalMessage)
    }
    
    Context {
        "*Branch*: \(meta.branch)"
        "*App version*: \(meta.version)"
        if let additionalContext {
            additionalContext
        }
    }
}

try await message.send(as: "slack_token")
```

## Result
<img width="559" height="140" alt="message_example" src="https://github.com/user-attachments/assets/3794b745-a295-4031-9491-87af0f0feb41" />

### Supported blocks

- Links
- Field sections
- User and group mentions
- Context

### Attachments

Slackito also supports sending attachments including images, CSV files, and other file types. Use raw data to attach files to a message. For images use `ImageAccessory` in MarkdownSection/PlainSection or `Image` block for full-sized images.

```swift
let csv: String = "Key, Name, Date\n..."
let csvAttachment = SlackAttachment(type: .fileData(csv.data(encoding: .utf8), filename: report.csv))

let message = SlackMessage(
    channel: "reports",
    attachments: [csvAttachment]
) {
    MarkdownSection(
        "📊 Here's the monthly report with data!",
        accessory: ImageAccessory(
            url: "https://example.com/image.jpg",
            text: "Report thumbnail"
        )
    )

    Image(url: "https://example.com/image.jpg", text: "report_jpg")
    
    Context {
        "*Generated on*: \(Date())"
        "*Data source*: Internal systems"
    }
}

try await message.send(as: "slack_token")
```

> Author: [@havebeenfitz](https://github.com/havebeenfitz)
