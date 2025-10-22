import Foundation
import Cronista

/// Root slack message entity holding a nested structure of DSL blocks
@MainActor
public struct SlackMessage: BlockConvertible {
    /// Channel id to post to.
    ///
    /// Better to have an id in a `C061Z3P47RB` format to use both post and update methods
    let channel: String
    /// Thread timestamp to reply to or update
    ///
    /// `ts` is provided in different formats  for both `post` and `update` methods
    let ts: String?
    /// Building blocks of a message
    ///
    /// Result builder DSL to make a message
    let blocks: [BlockConvertible]
    /// File attachments for the message
    let attachments: [SlackAttachment]

    let logger = Cronista(module: "Slackito", category: "SlackMessage")

    public var json: String {
        if let ts {
            """
            { "channel": "\(channel)", "thread_ts": "\(ts)", "ts": "\(ts)", "blocks": [ \(blocks.json) ] }
            """
        } else {
            """
            { "channel": "\(channel)", "blocks": [ \(blocks.json) ] }
            """
        }
    }
    
    public init(channel: String, ts: String? = nil, @SlackMessageBuilder _ makeBlocks: () -> [BlockConvertible]) {
        self.channel = channel
        self.ts = ts
        self.blocks = makeBlocks()
        self.attachments = []
    }
    
    public init(channel: String, ts: String? = nil, attachments: [SlackAttachment] = [], @SlackMessageBuilder _ makeBlocks: () -> [BlockConvertible]) {
        self.channel = channel
        self.ts = ts
        self.blocks = makeBlocks()
        self.attachments = attachments
    }

    public init(channel: String, ts: String? = nil, blocks: [BlockConvertible], attachments: [SlackAttachment] = []) {
        self.channel = channel
        self.ts = ts
        self.blocks = blocks
        self.attachments = attachments
    }
}
