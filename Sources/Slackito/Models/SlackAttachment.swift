import Foundation

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
        case .csv(let url, let filename):
            components.append("\"file_url\": \"\(url)\"")
            if let filename = filename {
                components.append("\"filename\": \"\(filename)\"")
            }
            components.append("\"filetype\": \"csv\"")
        case .csvData(_, let filename):
            if let filename = filename {
                components.append("\"filename\": \"\(filename)\"")
            }
            components.append("\"filetype\": \"csv\"")
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
    /// CSV file attachment from URL
    case csv(url: String, filename: String? = nil)
    /// CSV file attachment from local data
    case csvData(data: Data, filename: String? = nil)
}

/// Supported file types for attachments
public enum FileType: String, CaseIterable, Sendable {
    case csv = "csv"
    case pdf = "pdf"
    case txt = "txt"
    case json = "json"
    case xml = "xml"
    case zip = "zip"
    case doc = "doc"
    case docx = "docx"
    case xls = "xls"
    case xlsx = "xlsx"
    case ppt = "ppt"
    case pptx = "pptx"
    case jpeg = "jpeg"
    case png = "png"
    case gif = "gif"
    case mp4 = "mp4"
    case mov = "mov"
    case mp3 = "mp3"
    case wav = "wav"
    
    /// MIME type for the file type
    public var mimeType: String {
        switch self {
        case .csv: "text/csv"
        case .pdf: "application/pdf"
        case .txt: "text/plain"
        case .json: "application/json"
        case .xml: "application/xml"
        case .zip: "application/zip"
        case .doc: "application/msword"
        case .docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .xls: "application/vnd.ms-excel"
        case .xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .ppt: "application/vnd.ms-powerpoint"
        case .pptx: "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case .jpeg: "image/jpeg"
        case .png: "image/png"
        case .gif: "image/gif"
        case .mp4: "video/mp4"
        case .mov: "video/quicktime"
        case .mp3: "audio/mpeg"
        case .wav: "audio/wav"
        }
    }
}

// MARK: - Convenience Initializers

public extension SlackAttachment {
    /// Create an image attachment from URL
    static func image(url: String, altText: String? = nil, title: String? = nil, fallback: String? = nil) -> SlackAttachment {
        SlackAttachment(
            type: .image(url: url, altText: altText),
            title: title,
            fallback: fallback
        )
    }
    
    /// Create a CSV attachment from URL
    static func csv(url: String, filename: String? = nil, title: String? = nil, fallback: String? = nil) -> SlackAttachment {
        SlackAttachment(
            type: .csv(url: url, filename: filename),
            title: title,
            fallback: fallback
        )
    }
    
    /// Create a CSV attachment from local data
    static func csv(data: Data, filename: String? = nil, title: String? = nil, fallback: String? = nil) -> SlackAttachment {
        SlackAttachment(
            type: .csvData(data: data, filename: filename),
            title: title,
            fallback: fallback
        )
    }
    
    /// Create a file attachment from URL
    static func file(url: String, filename: String, fileType: FileType, title: String? = nil, fallback: String? = nil) -> SlackAttachment {
        SlackAttachment(
            type: .file(url: url, filename: filename, fileType: fileType),
            title: title,
            fallback: fallback
        )
    }
    
    /// Create a file attachment from local data
    static func file(data: Data, filename: String, fileType: FileType, title: String? = nil, fallback: String? = nil) -> SlackAttachment {
        SlackAttachment(
            type: .fileData(data: data, filename: filename, fileType: fileType),
            title: title,
            fallback: fallback
        )
    }
}
