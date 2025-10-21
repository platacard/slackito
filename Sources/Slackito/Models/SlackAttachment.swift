import Foundation
import UniformTypeIdentifiers

/// Represents a file attachment for Slack messages
public struct SlackAttachment: Sendable {
    /// The type of attachment
    public let type: AttachmentType
    /// Optional title for the attachment
    public let title: String?
    /// Optional fallback text for the attachment
    public let fallback: String?
    /// Optional color for the attachment (hex color code)
    public let color: String?
    /// Optional text content for the attachment
    public let text: String?

    public init(
        type: AttachmentType,
        title: String? = nil,
        fallback: String? = nil,
        color: String? = nil,
        text: String? = nil
    ) {
        self.type = type
        self.title = title
        self.fallback = fallback
        self.color = color
        self.text = text
    }

    /// JSON representation of the attachment for Slack API
    public var json: String {
        var components: [String] = []

        // Add title if present
        if let title = title {
            components.append("\"title\": \"\(title)\"")
        }

        // Add fallback if present
        if let fallback = fallback {
            components.append("\"fallback\": \"\(fallback)\"")
        }

        // Add color if present
        if let color = color {
            components.append("\"color\": \"\(color)\"")
        }

        // Add text if present
        if let text = text {
            components.append("\"text\": \"\(text)\"")
        }

        // Add type-specific fields
        switch type {
        case .image(let url, let altText):
            components.append("\"image_url\": \"\(url)\"")
            if let altText = altText {
                components.append("\"alt_text\": \"\(altText)\"")
            }
        case .file(let url, let filename, let fileType):
            components.append("\"file_url\": \"\(url)\"")
            components.append("\"filename\": \"\(filename)\"")
            components.append("\"filetype\": \"\(fileType.rawValue)\"")
        case .fileData(_, let filename, let fileType):
            components.append("\"filename\": \"\(filename)\"")
            components.append("\"filetype\": \"\(fileType.rawValue)\"")
        }

        return "{ \(components.joined(separator: ", ")) }"
    }
}

/// Types of attachments supported
public enum AttachmentType: Sendable {
    /// Image attachment from URL
    case image(url: String, altText: String? = nil)
    /// File attachment from URL
    case file(url: String, filename: String, fileType: FileType)
    /// File attachment from local data
    case fileData(data: Data, filename: String, fileType: FileType)
}

/// Supported file types for attachments
public enum FileType: String, CaseIterable, Sendable {
    case csv, pdf, txt, json, xml, zip, jpeg, png, gif, mp4, mov, mp3

    /// MIME type for the file type
    public var mimeType: String? {
        switch self {
        case .csv: UTType.commaSeparatedText.preferredMIMEType
        case .pdf: UTType.pdf.preferredMIMEType
        case .txt: UTType.text.preferredMIMEType
        case .json: UTType.json.preferredMIMEType
        case .xml: UTType.xml.preferredMIMEType
        case .zip: UTType.zip.preferredMIMEType
        case .jpeg: UTType.jpeg.preferredMIMEType
        case .png: UTType.png.preferredMIMEType
        case .gif: UTType.gif.preferredMIMEType
        case .mp4: UTType.mpeg4Movie.preferredMIMEType
        case .mov: UTType.movie.preferredMIMEType
        case .mp3: UTType.mp3.preferredMIMEType
        }
    }
}

// MARK: - Convenience Initializers

public extension SlackAttachment {

    static func image(url: String, altText: String? = nil, title: String? = nil, fallback: String? = nil) -> SlackAttachment {
        SlackAttachment(
            type: .image(url: url, altText: altText),
            title: title,
            fallback: fallback
        )
    }

    static func file(url: String, filename: String, fileType: FileType, title: String? = nil, fallback: String? = nil) -> SlackAttachment {
        SlackAttachment(
            type: .file(url: url, filename: filename, fileType: fileType),
            title: title,
            fallback: fallback
        )
    }

    static func file(data: Data, filename: String, fileType: FileType, title: String? = nil, fallback: String? = nil) -> SlackAttachment {
        SlackAttachment(
            type: .fileData(data: data, filename: filename, fileType: fileType),
            title: title,
            fallback: fallback
        )
    }
}
