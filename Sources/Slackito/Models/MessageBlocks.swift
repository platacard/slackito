import Foundation

@MainActor
public protocol BlockConvertible: Sendable {
    var json: String { get }
}

public protocol PlainSectionConvertible: Sendable {
    var plainText: String { get }
}

public protocol MarkdownSectionConvertible: Sendable {
    var markdown: String { get }
}

/// Block to visually separate other blocks
public struct Divider: BlockConvertible {
    public var json: String {
        """
        { "type": "divider" }
        """
    }
    
    public init() {}
}

/// Header block. Plain text only, emoji possible
public struct Header: BlockConvertible {
    public var json: String {
        """
        { "type": "header", "text": { "type": "plain_text", "text": "\(header)" } }
        """
    }
    
    public let header: String
    
    public init(_ header: String) {
        self.header = header
    }
}

/// Markdown text section. Used both inside `FieldsSection` and without it
public struct MarkdownSection: MarkdownSectionConvertible, BlockConvertible {
    public var json: String {
        """
        { "type": "section", "text": { "type": "mrkdwn", "text": "\(markdown)" } }
        """
    }
    
    public let markdown: String
    
    public init(_ markdown: String) {
        self.markdown = markdown
    }
}

/// Plain text section, used in the message body to send a simple text
public struct PlainSection: PlainSectionConvertible & BlockConvertible {
    public var json: String {
        """
        { "type": "section", "text": { "type": "plain_text", "text": "\(plainText)" } }
        """
    }
    
    public let plainText: String
    
    public init(_ plainText: String) {
        self.plainText = plainText
    }
}

/// Rows of markdown text sections wrapping horizontally,
/// 2 columns in a row on desktop, 1 column on mobile
public struct FieldsSection: BlockConvertible {
    public var json: String {
        let formattedSections = sections.map {
        """
        { "type": "mrkdwn", "text": "\($0.markdown)" }
        """
        }.joined(separator: ", ")
        
        return """
        { "type": "section", "fields": [ \(formattedSections) ] }
        """
    }

    public let sections: [MarkdownSectionConvertible]
    
    public init(@SlackMessageMarkdownSectionBuilder _ sections: () -> [MarkdownSectionConvertible]) {
        self.sections = sections()
    }
}

/// Usually used at the bottom of the message to provide some kind of context, e.g. app version or branch
public struct Context: BlockConvertible {
    public var json: String {
        let elements = markdownElements.map {
        """
        { "type": "mrkdwn", "text": "\($0.markdown)" }
        """
        }.joined(separator: ", ")
        
        return """
        { "type": "context", "elements": [ \(elements) ] }
        """
    }
    
    public let markdownElements: [MarkdownSectionConvertible]
    
    public init(@SlackMessageMarkdownSectionBuilder _ markdownElements: () -> [MarkdownSectionConvertible]) {
        self.markdownElements = markdownElements()
    }
}
