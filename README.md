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

Slackito also supports sending attachments including images, CSV files, and other file types:

```swift
let message = SlackMessage(
    channel: "reports",
    attachments: [imageAttachment, csvAttachment, csvDataAttachment]
) {
    MarkdownSection("📊 Here's the monthly report with data!")
    Context {
        "*Generated on*: \(Date())"
        "*Data source*: Internal systems"
    }
}

try await message.send(as: "slack_token")
```

#### Supported File Types

- **Images**: JPEG, PNG, GIF
- **Documents**: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX
- **Data**: CSV, JSON, XML, TXT
- **Archives**: ZIP
- **Media**: MP4, MOV, MP3, WAV

#### Attachment Types

- **URL-based**: Attach files from web URLs
- **Data-based**: Attach files from local data (automatically uploaded to Slack)
- **Images**: Special handling for image attachments with alt text support

> Author: [@havebeenfitz](https://github.com/havebeenfitz)