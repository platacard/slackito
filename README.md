# Slackito

A client written with result builders to work with Slack Web API. A small part of the larger iOS deploy infrastructure at Plata.


## Usage


```swift
let meta = try meta(stage: stage, configPath: bundleId.configPath)

let message = SlackMessage(channel: channel, ts: thread) {
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

return message
```

## Result
<img width="559" height="140" alt="message_example" src="https://github.com/user-attachments/assets/3794b745-a295-4031-9491-87af0f0feb41" />

## Supported blocks

- Links
- Field sections
- User and group mentions
- Context

## TODO

- Images
- Tables
