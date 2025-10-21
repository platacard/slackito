import Foundation

extension SlackMessage {

    @discardableResult
    public func send(as appToken: String?) async throws -> MessageMeta {
        let api = try Slackito(appToken: appToken)
        
        // Handle file uploads first if any attachments contain file data
        var processedAttachments = attachments
        for (index, attachment) in attachments.enumerated() {
            switch attachment.type {
            case .fileData(let data, let filename, let fileType):
                let uploadResponse = try await api.uploadFile(
                    data: data,
                    filename: filename,
                    fileType: fileType.rawValue,
                    channels: [channel]
                )
                
                guard uploadResponse.ok, let fileInfo = uploadResponse.file else {
                    throw NSError(domain: "File upload failed: \(uploadResponse.error ?? "Unknown error")", code: 2)
                }
                
                // Replace the fileData attachment with a file URL attachment
                let newAttachment = SlackAttachment(
                    type: .file(url: fileInfo.urlPrivate, filename: fileInfo.name, fileType: fileType),
                    title: attachment.title,
                    fallback: attachment.fallback,
                    color: attachment.color,
                    text: attachment.text
                )
                processedAttachments[index] = newAttachment
                
            case .csvData(let data, let filename):
                let uploadResponse = try await api.uploadFile(
                    data: data,
                    filename: filename ?? "data.csv",
                    fileType: "csv",
                    channels: [channel]
                )
                
                guard uploadResponse.ok, let fileInfo = uploadResponse.file else {
                    throw NSError(domain: "CSV upload failed: \(uploadResponse.error ?? "Unknown error")", code: 2)
                }
                
                // Replace the csvData attachment with a csv URL attachment
                let newAttachment = SlackAttachment(
                    type: .csv(url: fileInfo.urlPrivate, filename: fileInfo.name),
                    title: attachment.title,
                    fallback: attachment.fallback,
                    color: attachment.color,
                    text: attachment.text
                )
                processedAttachments[index] = newAttachment
                
            default:
                // No processing needed for URL-based attachments
                break
            }
        }
        
        // Create a new message with processed attachments
        let messageWithProcessedAttachments = SlackMessage(
            channel: channel,
            ts: ts,
            attachments: processedAttachments
        ) {
            // Rebuild the blocks
            for block in blocks {
                block
            }
        }
        
        let response = try await api.sendRequest(
            endpoint: "chat.postMessage",
            body: messageWithProcessedAttachments.json,
            httpMethod: "POST"
        )
        
        guard response.ok else {
            throw NSError(domain: "Request failed with \(response)", code: 1)
        }
        
        return MessageMeta(timestamp: response.ts)
    }
    
    @discardableResult
    public func update(as appToken: String?) async throws -> MessageMeta {
        let api = try Slackito(appToken: appToken)
        let response = try await api.sendRequest(
            endpoint: "chat.update",
            body: json,
            httpMethod: "POST"
        )
        
        guard response.ok else {
            throw NSError(domain: "Request failed with \(response)", code: 1)
        }
        
        return MessageMeta(timestamp: response.ts)
    }
}

public extension SlackMessage {
    /// Message meta info representing a message  "id". Could be used to reply to a thread
    struct MessageMeta {
        public let timestamp: String?
    }
}
