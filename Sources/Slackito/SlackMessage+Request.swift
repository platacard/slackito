import Foundation

extension SlackMessage {

    @discardableResult
    public func send(as appToken: String?) async throws -> MessageMeta {
        let api = try Slackito(appToken: appToken)
        let processedAttachments = try await processAttachments(appToken: appToken, api: api)

        let rebuiltMessage = SlackMessage(
            channel: channel,
            ts: ts,
            blocks: blocks,
            attachments: processedAttachments
        )
        
        let response = try await api.sendRequest(
            endpoint: "chat.postMessage",
            body: rebuiltMessage.json,
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
        let processedAttachments = try await processAttachments(appToken: appToken, api: api)

        let rebuiltMessage = SlackMessage(
            channel: channel,
            ts: ts,
            blocks: blocks,
            attachments: processedAttachments
        )

        let response = try await api.sendRequest(
            endpoint: "chat.update",
            body: rebuiltMessage.json,
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

// MARK: - Attachments

private extension SlackMessage {

    func processAttachments(appToken: String?, api: Slackito) async throws -> [SlackAttachment] {
        let api = try Slackito(appToken: appToken)
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
            default:
                // No processing needed for URL-based attachments
                break
            }
        }

        return processedAttachments
    }
}
