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

    private let logger = Cronista(module: "Slackito", category: "default")
    private let verbose: Bool

    init(
        appToken: String?,
        session: URLSession = .shared,
        maxRetryAttempts: Int = 3,
        verbose: Bool = false
    ) throws {
        guard let appToken else { throw ClientError.slackTokenRequired }
        
        self.appToken = appToken
        self.session = session
        self.maxRetryAttempts = maxRetryAttempts
        self.verbose = verbose
    }
    
    
    func sendRequest<R: Response>(
        endpoint: String,
        queryItems: [String: String] = [:],
        body: Data? = nil,
        httpMethod: String?
    ) async throws -> R {
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
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
        request.httpMethod = httpMethod

        if let body {
            request.httpBody = body
        }

        do {
            logger.debug("Starting the request: \(request.debugDescription)")

            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                logger.error("request \(request) failed. Response: \(response)")
                throw URLError(.badServerResponse)
            }

            if verbose {
                logger.debug("Response: \(response)")
                logger.debug("Response data: \(String(data: data, encoding: .utf8) ?? "")")
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result =  try decoder.decode(R.self, from: data)
            
            currentRetryAttempt = 0

            return result
        } catch let DecodingError.typeMismatch(type, context) {
            logger.error("Type '\(type)' mismatch:, \(context.debugDescription)")
            logger.error("codingPath: \(context.codingPath)")
            throw NSError(domain: "SlackAPI decoding failed", code: -1)
        } catch {
            logger.error("Request: \(request.description) failed with \(error)")

            if currentRetryAttempt < maxRetryAttempts {
                currentRetryAttempt += 1
                let retryBackoff = 5 * (1 + currentRetryAttempt)
                logger.warning("Retrying after \(retryBackoff)s")
                try await Task.sleep(for: .seconds(retryBackoff))

                return try await sendRequest(endpoint: endpoint, queryItems: queryItems, body: body, httpMethod: httpMethod)
            } else {
                let maxRetryAttempts = maxRetryAttempts
                logger.error("Retry failed \(maxRetryAttempts) times. Failing the request")
                throw NSError(domain: "SlackAPI retry failed", code: -1)
            }
        }
    }
}

// MARK: - Extensions

extension Slackito {

    protocol Response: Decodable {
        /// Response status
        var ok: Bool { get }
        /// Optional error if `ok == false`
        var error: String? { get }
    }

    struct ChatResponse: Response {
        let ok: Bool
        let error: String?
        let ts: String?
    }

    struct FileUploadStartResponse: Response {
        let ok: Bool
        let error: String?
        let uploadUrl: URL
        let fileId: String
    }
    struct File: Codable {
        let id: String
        let timestamp: Int?
    }

    struct FileUploadFinishedRequest: Encodable {
        let files: [File]
        let channelId: String
        let threadTs: String?
        let blocks: String
    }

    struct FileUploadFinishedResponse: Response {
        let ok: Bool
        let error: String?
        let ts: String?
        let files: [File]
    }

    enum ClientError: Swift.Error {
        case slackTokenRequired
        case invalidSlackURL
    }
}
