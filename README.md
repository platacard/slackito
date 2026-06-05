# <img width=30 style="float:left; margin-bottom:20px" alt="slackito_2" src="https://github.com/user-attachments/assets/f59d9796-f827-4bd8-bffd-84ab598d0373" /> Slackito
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->




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
- Action buttons

### Action buttons

Use the `Actions` block with one or more `Button` elements to add clickable link buttons. A button with a `url` opens it in the browser on click.

```swift
let message = SlackMessage(channel: "reports") {
    MarkdownSection("UI tests finished :white_check_mark:")
    Actions {
        Button("Gitlab job", url: jobUrl)
        Button("Allure launch", url: allureUrl)
    }
}
```

You can also build the block from an array of buttons, e.g. when filtering out entries without a URL:

```swift
Actions(buttons) // buttons: [Button]
```

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

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Egor-Danilov"><img src="https://avatars.githubusercontent.com/u/37295385?v=4?s=100" width="100px;" alt="decoder"/><br /><sub><b>decoder</b></sub></a><br /><a href="https://github.com/platacard/slackito/commits?author=Egor-Danilov" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

> Author: [@havebeenfitz](https://github.com/havebeenfitz)
