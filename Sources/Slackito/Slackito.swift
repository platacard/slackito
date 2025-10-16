import Foundation
import Cronista

/// Internal implementation.
///
/// Use SlackMessage builder to send a message.
actor Slackito {
    private let session: URLSession
    private let appToken: String
    private let baseUrl = URL(string: "https://slack.com/api/")

    private let maxRetryAttempts: Int
    private var currentRetryAttempt = 0

    private let logger = Cronista.default
    
    init(
        appToken: String?,
        session: URLSession = .shared,
        maxRetryAttempts: Int = 3
    ) throws {
        guard let appToken else { throw ClientError.slackTokenRequired }
        
        self.appToken = appToken
        self.session = session
        self.maxRetryAttempts = maxRetryAttempts
    }
    
    
    func sendRequest(
        endpoint: String,
        queryItems: [String: String] = [:],
        body: String = "",
        httpMethod: String?
    ) async throws -> Response {
        guard
            let baseUrl,
            let url = URL(string: baseUrl.absoluteString + endpoint)?.appending(
                queryItems: queryItems.map(URLQueryItem.init)
            )
        else {
            throw ClientError.invalidSlackURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(appToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        request.httpBody = body.data(using: .utf8)

        do {
            logger.debug("[Slack API] starting the request: \(request.debugDescription)")

            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                logger.error("[Slack API] request \(request) failed. Response: \(response)")
                throw URLError(.badServerResponse)
            }

            currentRetryAttempt = 0

            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            logger.debug("[Slack API] request: \(request.debugDescription) failed with \(error.localizedDescription)")

            if currentRetryAttempt < maxRetryAttempts {
                currentRetryAttempt += 1
                let retryBackoff = 5 * (1 + currentRetryAttempt)
                logger.debug("[Slack API] retrying after \(retryBackoff)s")
                try await Task.sleep(for: .seconds(retryBackoff))
                return try await sendRequest(endpoint: endpoint, queryItems: queryItems, body: body, httpMethod: httpMethod)
            } else {
                let maxRetryAttempts = maxRetryAttempts
                logger.error("[Slack API] retry failed \(maxRetryAttempts) times. Failing the request")
                throw NSError(domain: "SlackAPI retry failed", code: -1)
            }
        }
    }
}

// MARK: - Extensions

extension Slackito {
    struct Response: Decodable {
        /// Response status
        let ok: Bool
        /// Message timestamp to reply to a thread in a different message
        let ts: String?
        /// Optional error if `ok == false`
        let error: String?
    }
    
    enum ClientError: Swift.Error {
        case slackTokenRequired
        case invalidSlackURL
    }
}

