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
        let text = header.truncated(to: SlackLimits.headerText).jsonEscaped

        return #"{ "type": "header", "text": { "type": "plain_text", "text": "\#(text)" } }"#
    }

    public let header: String

    public init(_ header: String) {
        self.header = header
    }
}

/// Markdown text section. Used both inside `FieldsSection` and without it
public struct MarkdownSection: MarkdownSectionConvertible, BlockConvertible {
    public var json: String {
        let escaped = markdown.truncated(to: SlackLimits.sectionText).jsonEscaped
        let text = #"{ "type": "section", "text": { "type": "mrkdwn", "text": "\#(escaped)" }"#

        guard let accessoryJSON = accessory?.json else { return "\(text) }" }
        return "\(text), \(accessoryJSON) }"
    }

    public let markdown: String
    public let accessory: Accessory?

    public init(_ markdown: String, accessory: Accessory? = nil) {
        self.markdown = markdown
        self.accessory = accessory
    }

    @available(*, deprecated, message: "Use init(_:accessory:) with .image instead")
    public init(_ markdown: String, imageAccessory: ImageAccessory?) {
        self.markdown = markdown
        self.accessory = imageAccessory.map(Accessory.image)
    }

    @available(*, deprecated, message: "Use init(_:accessory:) with .button instead")
    public init(_ markdown: String, buttonAccessory: ButtonAccessory?) {
        self.markdown = markdown
        self.accessory = buttonAccessory.map { Accessory.button(Button($0.text, url: $0.url)) }
    }
}

/// Plain text section, used in the message body to send a simple text
public struct PlainSection: PlainSectionConvertible, BlockConvertible {
    public var json: String {
        let escaped = plainText.truncated(to: SlackLimits.sectionText).jsonEscaped
        let text = #"{ "type": "section", "text": { "type": "plain_text", "text": "\#(escaped)" }"#

        guard let accessoryJSON = accessory?.json else { return "\(text) }" }
        return "\(text), \(accessoryJSON) }"
    }

    public let plainText: String
    public let accessory: Accessory?

    public init(_ plainText: String, accessory: Accessory? = nil) {
        self.plainText = plainText
        self.accessory = accessory
    }

    @available(*, deprecated, message: "Use init(_:accessory:) with .image instead")
    public init(_ plainText: String, accessory: ImageAccessory?) {
        self.plainText = plainText
        self.accessory = accessory.map(Accessory.image)
    }
}

/// Rows of markdown text sections wrapping horizontally,
/// 2 columns in a row on desktop, 1 column on mobile
public struct FieldsSection: BlockConvertible {
    public var json: String {
        let formattedSections = sections.prefix(SlackLimits.fieldsPerSection).map {
            """
            { "type": "mrkdwn", "text": "\($0.markdown.truncated(to: SlackLimits.fieldText).jsonEscaped)" }
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

public struct Image: BlockConvertible {
    public var json: String {
        """
        {
            "type": "image",
            "title": {
                "type": "plain_text",
                "text": "\(text.jsonEscaped)",
                "emoji": true
            },
            "image_url": "\(url.jsonEscaped)",
            "alt_text": "\(text.jsonEscaped)"
        }
        """
    }

    public let url: String
    public let text: String

    public init(url: String, text: String) {
        self.url = url
        self.text = text
    }
}

public struct ImageAccessory: Sendable {
    @available(*, deprecated, message: "Use Accessory.image(_:) instead")
    public var json: String {
        #""accessory": \#(element)"#
    }

    var element: String {
        """
        { "type": "image", "image_url": "\(url.jsonEscaped)", "alt_text": "\(text.jsonEscaped)" }
        """
    }

    public let url: String
    public let text: String

    public init(url: String, text: String) {
        self.url = url
        self.text = text
    }
}

@available(*, deprecated, message: "Use Accessory.button(Button(_:url:)) instead")
public struct ButtonAccessory: Sendable {
    public var json: String {
        #""accessory": \#(Button(text, url: url).json)"#
    }

    public let url: String
    public let text: String

    public init(url: String, text: String) {
        self.url = url
        self.text = text
    }
}

/// Usually used at the bottom of the message to provide some kind of context, e.g. app version or branch
public struct Context: BlockConvertible {
    public var json: String {
        let elements = markdownElements.prefix(SlackLimits.contextElements).map {
            """
            { "type": "mrkdwn", "text": "\($0.markdown.truncated(to: SlackLimits.fieldText).jsonEscaped)" }
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

/// Interactive button element used inside an `Actions` block.
///
/// When a `url` is provided, the button opens it in the browser on click.
public struct Button: Sendable {

    public enum Style: String, Sendable {
        case primary
        case danger
    }

    public var json: String {
        let escaped = text.truncated(to: SlackLimits.buttonText).jsonEscaped
        var fields = [
            #""type": "button""#,
            #""text": { "type": "plain_text", "text": "\#(escaped)", "emoji": true }"#
        ]

        if let url, !url.isEmpty {
            fields.append(#""url": "\#(url.jsonEscaped)""#)
        }
        if let style {
            fields.append(#""style": "\#(style.rawValue)""#)
        }
        if let actionId {
            fields.append(#""action_id": "\#(actionId.jsonEscaped)""#)
        }

        return "{ \(fields.joined(separator: ", ")) }"
    }

    public let text: String
    public let url: String?
    public let style: Style?
    public let actionId: String?

    public init(_ text: String, url: String? = nil, style: Style? = nil, actionId: String? = nil) {
        self.text = text
        self.url = url
        self.style = style
        self.actionId = actionId
    }
}

/// A block of interactive elements (currently buttons), rendered as a row of controls.
public struct Actions: BlockConvertible {
    public var json: String {
        let elements = buttons.prefix(SlackLimits.elementsPerActions).map { $0.json }.joined(separator: ", ")

        return """
        { "type": "actions", "elements": [ \(elements) ] }
        """
    }

    public let buttons: [Button]

    public init(_ buttons: [Button]) {
        self.buttons = buttons
    }

    public init(@SlackMessageButtonBuilder _ buttons: () -> [Button]) {
        self.buttons = buttons()
    }
}
