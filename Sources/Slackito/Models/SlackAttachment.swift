import Foundation
import UniformTypeIdentifiers

/// Represents a file attachment for Slack messages
public struct SlackAttachment: Sendable {
    /// The type of attachment
    public let type: AttachmentType
    public let text: String?

    public init(
        type: AttachmentType,
        text: String? = nil
    ) {
        self.type = type
        self.text = text
    }
}

/// Types of attachments supported
public enum AttachmentType: Sendable {
    /// Image attachment from URL
    case image(url: String, altText: String? = nil)
    /// File attachment from URL
    case file(url: String, filename: String)
    /// File attachment from local data
    case fileData(data: Data, filename: String)
}
