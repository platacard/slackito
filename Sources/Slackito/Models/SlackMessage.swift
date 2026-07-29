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
        if let parent = threadTs ?? ts {
            fields.append(#""thread_ts": "\#(parent.jsonEscaped)""#)
        }
        if let notificationText {
            let text = notificationText.truncated(to: SlackLimits.notificationText).jsonEscaped
            fields.append(#""text": "\#(text)""#)
        }
        let renderable = blocks.renderable
        if !renderable.isEmpty {
            fields.append("\"blocks\": [ \(renderable.json) ]")
        }

        return "{ \(fields.joined(separator: ", ")) }"
    }

    public func validate() throws {
        let renderable = blocks.renderable

        guard !renderable.isEmpty || !attachments.isEmpty || notificationText != nil else {
            throw SlackMessageError.emptyMessage
        }
        guard renderable.count <= SlackLimits.blocksPerMessage else {
            throw SlackMessageError.tooManyBlocks(count: renderable.count, limit: SlackLimits.blocksPerMessage)
        }
    }

    var notificationText: String? {
        if let text, !text.isEmpty { return text }
        for block in blocks {
            if let fallback = (block as? FallbackTextProviding)?.fallbackText { return fallback }
        }
        return nil
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
