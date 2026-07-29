import Foundation
#if os(macOS)
import Cronista
#else
import Logging
#endif

/// Root slack message entity holding a nested structure of DSL blocks
@MainActor
public struct SlackMessage: BlockConvertible {
    /// Channel id to post to.
    ///
    /// Better to have an id in a `C061Z3P47RB` format to use both post and update methods
    let channel: String
    /// Timestamp of the message to update
    let ts: String?
    /// Timestamp of the parent message to reply to
    let threadTs: String?
    /// Notification fallback shown in push notifications and in the channel list
    ///
    /// Derived from the first block that carries text when not provided
    let text: String?
    /// Building blocks of a message
    ///
    /// Result builder DSL to make a message
    let blocks: [BlockConvertible]
    /// File attachments for the message
    let attachments: [SlackAttachment]

    #if os(macOS)
    let logger = Cronista(module: "Slackito", category: "SlackMessage")
    #else
    let logger = Logger(label: "Slackito.SlackMessage")
    #endif

    public var json: String {
        var fields = [#""channel": "\#(channel.jsonEscaped)""#]

        if let ts {
            fields.append(#""ts": "\#(ts.jsonEscaped)""#)
        }
        if let threadTs {
            fields.append(#""thread_ts": "\#(threadTs.jsonEscaped)""#)
        }
        if let notificationText {
            fields.append(#""text": "\#(notificationText.jsonEscaped)""#)
        }
        fields.append("\"blocks\": [ \(blocks.json) ]")

        return "{ \(fields.joined(separator: ", ")) }"
    }

    var notificationText: String? {
        if let text, !text.isEmpty { return text }
        return blocks.lazy.compactMap { ($0 as? FallbackTextProviding)?.fallbackText }.first
    }

    public init(
        channel: String,
        ts: String? = nil,
        threadTs: String? = nil,
        text: String? = nil,
        @SlackMessageBuilder _ makeBlocks: () -> [BlockConvertible]
    ) {
        self.channel = channel
        self.ts = ts
        self.threadTs = threadTs
        self.text = text
        self.blocks = makeBlocks()
        self.attachments = []
    }

    public init(
        channel: String,
        ts: String? = nil,
        threadTs: String? = nil,
        text: String? = nil,
        attachments: [SlackAttachment] = [],
        @SlackMessageBuilder _ makeBlocks: () -> [BlockConvertible]
    ) {
        self.channel = channel
        self.ts = ts
        self.threadTs = threadTs
        self.text = text
        self.blocks = makeBlocks()
        self.attachments = attachments
    }

    public init(
        channel: String,
        ts: String? = nil,
        threadTs: String? = nil,
        text: String? = nil,
        blocks: [BlockConvertible],
        attachments: [SlackAttachment] = []
    ) {
        self.channel = channel
        self.ts = ts
        self.threadTs = threadTs
        self.text = text
        self.blocks = blocks
        self.attachments = attachments
    }
}
