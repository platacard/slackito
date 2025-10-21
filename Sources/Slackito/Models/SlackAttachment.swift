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
    case jpg = "jpg"
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
        case .csv: return "text/csv"
        case .pdf: return "application/pdf"
        case .txt: return "text/plain"
        case .json: return "application/json"
        case .xml: return "application/xml"
        case .zip: return "application/zip"
        case .doc: return "application/msword"
        case .docx: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .xls: return "application/vnd.ms-excel"
        case .xlsx: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .ppt: return "application/vnd.ms-powerpoint"
        case .pptx: return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case .jpg, .jpeg: return "image/jpeg"
        case .png: return "image/png"
        case .gif: return "image/gif"
        case .mp4: return "video/mp4"
        case .mov: return "video/quicktime"
        case .mp3: return "audio/mpeg"
        case .wav: return "audio/wav"
        }
    }
    
    /// Whether this file type is an image
    public var isImage: Bool {
        switch self {
        case .jpg, .jpeg, .png, .gif:
            return true
        default:
            return false
        }
    }
    
    /// Whether this file type is a video
    public var isVideo: Bool {
        switch self {
        case .mp4, .mov:
            return true
        default:
            return false
        }
    }
    
    /// Whether this file type is an audio file
    public var isAudio: Bool {
        switch self {
        case .mp3, .wav:
            return true
        default:
            return false
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
