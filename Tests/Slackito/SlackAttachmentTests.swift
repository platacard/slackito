import XCTest
@testable import Slackito

@MainActor
final class SlackAttachmentTests: XCTestCase {
    
    func test_ImageAttachmentProducesCorrectJson() throws {
        let attachment = SlackAttachment.image(
            url: "https://example.com/image.jpg",
            altText: "Test image",
            title: "My Image",
            fallback: "Image: My Image"
        )
        
        let expected = """
        { "title": "My Image", "fallback": "Image: My Image", "image_url": "https://example.com/image.jpg", "alt_text": "Test image" }
        """
        
        XCTAssertEqual(attachment.json, expected)
    }
    
    func test_ImageAttachmentWithoutOptionalFieldsProducesCorrectJson() throws {
        let attachment = SlackAttachment.image(url: "https://example.com/image.jpg")
        
        let expected = """
        { "image_url": "https://example.com/image.jpg" }
        """
        
        XCTAssertEqual(attachment.json, expected)
    }
    
    func test_CsvAttachmentFromUrlProducesCorrectJson() throws {
        let attachment = SlackAttachment.csv(
            url: "https://example.com/data.csv",
            filename: "report.csv",
            title: "Monthly Report",
            fallback: "CSV: Monthly Report"
        )
        
        let expected = """
        { "title": "Monthly Report", "fallback": "CSV: Monthly Report", "file_url": "https://example.com/data.csv", "filename": "report.csv", "filetype": "csv" }
        """
        
        XCTAssertEqual(attachment.json, expected)
    }
    
    func test_FileAttachmentFromUrlProducesCorrectJson() throws {
        let attachment = SlackAttachment.file(
            url: "https://example.com/document.pdf",
            filename: "document.pdf",
            fileType: .pdf,
            title: "Important Document",
            fallback: "PDF: Important Document"
        )
        
        let expected = """
        { "title": "Important Document", "fallback": "PDF: Important Document", "file_url": "https://example.com/document.pdf", "filename": "document.pdf", "filetype": "pdf" }
        """
        
        XCTAssertEqual(attachment.json, expected)
    }
    
    func test_FileTypeMimeTypes() throws {
        XCTAssertEqual(FileType.csv.mimeType, "text/csv")
        XCTAssertEqual(FileType.pdf.mimeType, "application/pdf")
        XCTAssertEqual(FileType.jpg.mimeType, "image/jpeg")
        XCTAssertEqual(FileType.png.mimeType, "image/png")
        XCTAssertEqual(FileType.mp4.mimeType, "video/mp4")
        XCTAssertEqual(FileType.mp3.mimeType, "audio/mpeg")
    }
    
    func test_FileTypeCategories() throws {
        XCTAssertTrue(FileType.jpg.isImage)
        XCTAssertTrue(FileType.png.isImage)
        XCTAssertTrue(FileType.gif.isImage)
        XCTAssertFalse(FileType.csv.isImage)
        
        XCTAssertTrue(FileType.mp4.isVideo)
        XCTAssertTrue(FileType.mov.isVideo)
        XCTAssertFalse(FileType.jpg.isVideo)
        
        XCTAssertTrue(FileType.mp3.isAudio)
        XCTAssertTrue(FileType.wav.isAudio)
        XCTAssertFalse(FileType.mp4.isAudio)
    }
    
    func test_MessageWithAttachmentsProducesCorrectJson() throws {
        let attachment = SlackAttachment.image(url: "https://example.com/image.jpg", title: "Test Image")
        let message = SlackMessage(channel: "test_channel", attachments: [attachment]) {
            MarkdownSection("Here's an image!")
        }
        
        let expected = """
        { "channel": "test_channel", "blocks": [ { "type": "section", "text": { "type": "mrkdwn", "text": "Here's an image!" } } ], "attachments": [ { "title": "Test Image", "image_url": "https://example.com/image.jpg" } ] }
        """
        
        XCTAssertEqual(message.json, expected)
    }
    
    func test_MessageWithMultipleAttachmentsProducesCorrectJson() throws {
        let imageAttachment = SlackAttachment.image(url: "https://example.com/image.jpg", title: "Image")
        let csvAttachment = SlackAttachment.csv(url: "https://example.com/data.csv", filename: "data.csv", title: "Data")
        
        let message = SlackMessage(channel: "test_channel", attachments: [imageAttachment, csvAttachment]) {
            MarkdownSection("Multiple attachments!")
        }
        
        let expected = """
        { "channel": "test_channel", "blocks": [ { "type": "section", "text": { "type": "mrkdwn", "text": "Multiple attachments!" } } ], "attachments": [ { "title": "Image", "image_url": "https://example.com/image.jpg" }, { "title": "Data", "file_url": "https://example.com/data.csv", "filename": "data.csv", "filetype": "csv" } ] }
        """
        
        XCTAssertEqual(message.json, expected)
    }
    
    func test_MessageWithoutAttachmentsProducesCorrectJson() throws {
        let message = SlackMessage(channel: "test_channel") {
            MarkdownSection("No attachments")
        }
        
        let expected = """
        { "channel": "test_channel", "blocks": [ { "type": "section", "text": { "type": "mrkdwn", "text": "No attachments" } } ] }
        """
        
        XCTAssertEqual(message.json, expected)
    }
    
    func test_MessageWithThreadAndAttachmentsProducesCorrectJson() throws {
        let attachment = SlackAttachment.csv(url: "https://example.com/data.csv", filename: "data.csv")
        let message = SlackMessage(channel: "test_channel", ts: "1234567890.123456", attachments: [attachment]) {
            MarkdownSection("Thread reply with attachment")
        }
        
        let expected = """
        { "channel": "test_channel", "thread_ts": "1234567890.123456", "ts": "1234567890.123456", "blocks": [ { "type": "section", "text": { "type": "mrkdwn", "text": "Thread reply with attachment" } } ], "attachments": [ { "file_url": "https://example.com/data.csv", "filename": "data.csv", "filetype": "csv" } ] }
        """
        
        XCTAssertEqual(message.json, expected)
    }
}
