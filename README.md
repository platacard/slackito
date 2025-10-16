# Slackito

A client written with result builders to work with Slack Web API.


## Usage


```swift
let message = SlackMessage(channel: "test-ios-channel-2") {
    Header("Some header")
    PlainSection("A plain text example")
    
    Divider()
    
    FieldsSection {
        MarkdownSection("Section 1:\n *text 1*")
        MarkdownSection("Section 2:\n text 2")
    }
    
    Context {
        "Branch: release"
    }
}

do {
    try await message.send(as: {bot_token_here})
} catch {
    print(error)
}
```
