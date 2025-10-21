import Foundation

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
    
    public var json: String {
        let blocksJson = blocks.json
        let attachmentsJson = attachments.isEmpty ? "" : ", \"attachments\": [ \(attachments.map(\.json).joined(separator: ", ")) ]"
        
        if let ts {
            return """
            { "channel": "\(channel)", "thread_ts": "\(ts)", "ts": "\(ts)", "blocks": [ \(blocksJson) ]\(attachmentsJson) }
            """
        } else {
            return """
            { "channel": "\(channel)", "blocks": [ \(blocksJson) ]\(attachmentsJson) }
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
}
