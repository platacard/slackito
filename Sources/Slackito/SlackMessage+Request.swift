import Foundation

extension SlackMessage {

    @discardableResult
    public func send(as appToken: String?) async throws -> MessageMeta {
        let api = try Slackito(appToken: appToken)
        let response = try await api.sendRequest(
            endpoint: "chat.postMessage",
            body: json,
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
