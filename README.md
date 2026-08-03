# <img width=30 style="float:left; margin-bottom:20px" alt="slackito_2" src="https://github.com/user-attachments/assets/f59d9796-f827-4bd8-bffd-84ab598d0373" /> Slackito
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-2-orange.svg?style=flat-square)](#contributors-)
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

let message = SlackMessage(channel: "some_channel", threadTs: "parent_timestamp") {
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
        accessory: .image(ImageAccessory(
            url: "https://example.com/image.jpg",
            text: "Report thumbnail"
        ))
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
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/memoto"><img src="https://avatars.githubusercontent.com/u/16154570?v=4?s=100" width="100px;" alt="Konstantin Iurichev"/><br /><sub><b>Konstantin Iurichev</b></sub></a><br /><a href="https://github.com/platacard/slackito/commits?author=memoto" title="Code">💻</a></td>
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

## Accessories

A section carries at most one accessory, expressed as an `Accessory`:

```swift
MarkdownSection("*PaymentsOnBuild*\n:approved: *Passed:* 9", accessory: .button(Button("Job", url: jobUrl)))
MarkdownSection("Report thumbnail", accessory: .image(ImageAccessory(url: imageUrl, text: "thumbnail")))
MarkdownSection("*PaymentsOnBuild*", accessory: .overflow(Overflow(actionId: "report_links") {
    Overflow.Option(text: ":gitlab: Job", url: jobUrl)
    Overflow.Option(text: ":allure2: Launch", url: allureUrl)
}))
```

Overflow options open their `url` in the browser, but Slack still dispatches a
`block_actions` payload for the click. An app without an interactivity Request URL
that answers 200 within three seconds shows the user an error, so use an overflow
only from an app that handles interactions.

## Limits and validation

`SlackLimits` holds Slack's documented caps. Blocks truncate their text and drop
elements past a limit while rendering, and `SlackMessage.validate()` — called by
`send()` and `update()` — throws `SlackMessageError` before the request leaves the
process, so an oversized message fails with a diagnostic instead of a silent
`invalid_blocks`. Anything that was dropped is listed in `SlackMessage.warnings`
and logged on send.

A block that cannot be rendered legally — an empty header, an empty section, an
actions row with no buttons — is left out of the payload rather than sent for
Slack to reject.

## Migrating from 1.x

- **Escaping moved into the package.** Blocks now escape every string they
  interpolate. Delete your own JSON escaping, and pass real `"\n"` characters
  instead of a literal backslash-n — otherwise both are escaped twice and the
  escape sequences become visible text.
- **`text` is sent as the notification fallback.** It is derived from the first
  block that carries text when you do not pass `text:` explicitly.
- **`ts:` vs `threadTs:`.** `ts:` still acts as the thread parent, so existing
  replies keep working; use `threadTs:` for a reply and `ts:` for the message you
  are updating when you need to address them separately.
- **One accessory per section.** `imageAccessory:` / `buttonAccessory:` and the
  `ImageAccessory.json` / `ButtonAccessory` renderers still work and are
  deprecated in favour of `accessory:` with `.image` / `.button` / `.overflow`.
