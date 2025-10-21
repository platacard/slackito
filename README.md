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

Slackito now supports sending attachments including images, CSV files, and other file types:

```swift
// Image attachment from URL
let imageAttachment = SlackAttachment.image(
    url: "https://example.com/chart.png",
    altText: "Sales chart",
    title: "Monthly Sales Report"
)

// CSV attachment from URL
let csvAttachment = SlackAttachment.csv(
    url: "https://example.com/data.csv",
    filename: "sales_data.csv",
    title: "Sales Data"
)

// File attachment from local data
let csvData = "name,age\nJohn,30\nJane,25".data(using: .utf8)!
let csvDataAttachment = SlackAttachment.csv(
    data: csvData,
    filename: "users.csv",
    title: "User Data"
)

// Send message with attachments
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

- **Images**: JPG, JPEG, PNG, GIF
- **Documents**: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX
- **Data**: CSV, JSON, XML, TXT
- **Archives**: ZIP
- **Media**: MP4, MOV, MP3, WAV

#### Attachment Types

- **URL-based**: Attach files from web URLs
- **Data-based**: Attach files from local data (automatically uploaded to Slack)
- **Images**: Special handling for image attachments with alt text support

> Author: [@havebeenfitz](https://github.com/havebeenfitz)