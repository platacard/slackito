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
        { "type": "header", "text": { "type": "plain_text", "text": "\(header.jsonEscaped)" } }
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
        let text = """
        { "type": "section", "text": { "type": "mrkdwn", "text": "\(markdown.jsonEscaped)" }
        """

        if let imageAccessory {
            return "\(text), \(imageAccessory.json) }"
        } else if let buttonAccessory {
            return "\(text), \(buttonAccessory.json) }"
        } else {
            return "\(text) }"
        }
    }

    public let markdown: String
    public let imageAccessory: ImageAccessory?
    public let buttonAccessory: ButtonAccessory?

    public init(_ markdown: String, imageAccessory: ImageAccessory? = nil, buttonAccessory: ButtonAccessory? = nil) {
        self.markdown = markdown
        self.imageAccessory = imageAccessory
        self.buttonAccessory = buttonAccessory
    }
}

/// Plain text section, used in the message body to send a simple text
public struct PlainSection: PlainSectionConvertible, BlockConvertible {
    public var json: String {
        let text = """
        { "type": "section", "text": { "type": "plain_text", "text": "\(plainText.jsonEscaped)" }
        """

        if let accessory {
            return "\(text), \(accessory.json) }"
        } else {
            return "\(text) }"
        }
    }

    public let plainText: String
    public let accessory: ImageAccessory?

    public init(_ plainText: String, accessory: ImageAccessory? = nil) {
        self.plainText = plainText
        self.accessory = accessory
    }
}

/// Rows of markdown text sections wrapping horizontally,
/// 2 columns in a row on desktop, 1 column on mobile
public struct FieldsSection: BlockConvertible {
    public var json: String {
        let formattedSections = sections.map {
            """
            { "type": "mrkdwn", "text": "\($0.markdown.jsonEscaped)" }
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
    public var json: String {
        """
        "accessory": {
            "type": "image",
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

public struct ButtonAccessory: Sendable {
    public var json: String {
        """
        "accessory": {
            "type": "button",
            "text": {
                "type": "plain_text",
                "emoji": true,
                "text": "\(text.jsonEscaped)"
            },
            "url": "\(url.jsonEscaped)"
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

/// Usually used at the bottom of the message to provide some kind of context, e.g. app version or branch
public struct Context: BlockConvertible {
    public var json: String {
        let elements = markdownElements.map {
            """
            { "type": "mrkdwn", "text": "\($0.markdown.jsonEscaped)" }
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
    public var json: String {
        let element = """
        { "type": "button", "text": { "type": "plain_text", "text": "\(text.jsonEscaped)", "emoji": true }
        """

        if let url {
            return "\(element), \"url\": \"\(url.jsonEscaped)\" }"
        } else {
            return "\(element) }"
        }
    }

    public let text: String
    public let url: String?

    public init(_ text: String, url: String? = nil) {
        self.text = text
        self.url = url
    }
}

/// A block of interactive elements (currently buttons), rendered as a row of controls.
public struct Actions: BlockConvertible {
    public var json: String {
        let elements = buttons.map { $0.json }.joined(separator: ", ")

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
