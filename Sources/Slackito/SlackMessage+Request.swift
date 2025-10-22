import Foundation

extension SlackMessage {

    @discardableResult
    public func send(as appToken: String?) async throws -> MessageMeta {
        let api = try Slackito(appToken: appToken)

        if attachments.isEmpty {
            let response: Slackito.ChatResponse = try await api.sendRequest(
                endpoint: "chat.postMessage",
                body: json.data(using: .utf8),
                httpMethod: "POST"
            )

            guard response.ok else {
                throw NSError(domain: "Request failed with \(response)", code: 1)
            }

            return MessageMeta(timestamp: response.ts)
        } else {
            let response = try await sendWithAttachments(appToken: appToken, api: api)
            return MessageMeta(timestamp: response.timestamp)
        }
    }
    
    @discardableResult
    public func update(as appToken: String?) async throws -> MessageMeta {
        let api = try Slackito(appToken: appToken)

        if attachments.isEmpty {
            let response: Slackito.ChatResponse = try await api.sendRequest(
                endpoint: "chat.update",
                body: json.data(using: .utf8),
                httpMethod: "POST"
            )

            guard response.ok else {
                throw NSError(domain: "Request failed with \(response)", code: 1)
            }

            return MessageMeta(timestamp: response.ts)
        } else {
            let response = try await sendWithAttachments(appToken: appToken, api: api)
            return MessageMeta(timestamp: response.timestamp)
        }
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

    // https://docs.slack.dev/messaging/working-with-files/#uploading_files
    func sendWithAttachments(appToken: String?, api: Slackito) async throws -> MessageMeta {
        var files: [Slackito.FileUploadStartResponse] = []

        for attachment in attachments {
            switch attachment.type {
            case .fileData(let data, let filename):
                // 1. Get the URL to upload to
                let file: Slackito.FileUploadStartResponse = try await api.sendRequest(
                    endpoint: "files.getUploadURLExternal",
                    queryItems: ["filename": "\(filename)", "length": "\(data.count)"],
                    httpMethod: "POST"
                )

                guard file.ok else {
                    throw NSError(domain: "File upload failed: \(file.error ?? "Unknown error")", code: -1)
                }

                files.append(file)

                // 2. Upload raw bytes
                var uploadRequest = URLRequest(url: file.uploadUrl)
                uploadRequest.httpMethod = "POST"
                uploadRequest.httpBody = data
                uploadRequest.addValue(filename, forHTTPHeaderField: "filename")

                let (_, uploadResponse) = try await URLSession.shared.data(for: uploadRequest)
                guard let httpResponse = uploadResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "CSV data upload failed", code: 5)
                }
            default:
                break
            }
        }

        // 3. Finish the upload
        let requestJson = Slackito.FileUploadFinishedRequest(
            files: files.map { Slackito.File(id: $0.fileId, timestamp: nil) },
            channelId: channel,
            threadTs: ts,
            blocks: "[ \(blocks.json) ]"
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let data = try encoder.encode(requestJson)

        let completeResponse: Slackito.FileUploadFinishedResponse = try await api.sendRequest(
            endpoint: "files.completeUploadExternal",
            body: data,
            httpMethod: "POST"
        )

        let ts = String(completeResponse.files.first?.timestamp ?? 0)
        logger.info("First file timestamp: \(ts)")

        return MessageMeta(timestamp: ts)
    }
}
