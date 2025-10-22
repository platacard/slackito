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
    /// File attachment from local data
    case fileData(data: Data, filename: String)
}
