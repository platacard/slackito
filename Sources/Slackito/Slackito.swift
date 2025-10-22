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
            logger.debug("Starting the request: \(request.debugDescription)")

            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                logger.error("request \(request) failed. Response: \(response)")
                throw URLError(.badServerResponse)
            }

            currentRetryAttempt = 0

            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            logger.debug("Request: \(request.debugDescription) failed with \(error.localizedDescription)")

            if currentRetryAttempt < maxRetryAttempts {
                currentRetryAttempt += 1
                let retryBackoff = 5 * (1 + currentRetryAttempt)
                logger.debug("Retrying after \(retryBackoff)s")
                try await Task.sleep(for: .seconds(retryBackoff))
                return try await sendRequest(endpoint: endpoint, queryItems: queryItems, body: body, httpMethod: httpMethod)
            } else {
                let maxRetryAttempts = maxRetryAttempts
                logger.error("Retry failed \(maxRetryAttempts) times. Failing the request")
                throw NSError(domain: "SlackAPI retry failed", code: -1)
            }
        }
    }
    
    /// Upload a file to Slack
    func uploadFile(
        data: Data,
        filename: String,
        fileType: String,
        channels: [String] = []
    ) async throws -> FileUploadResponse {
        guard let baseUrl else { throw ClientError.invalidSlackURL }
        
        let url = URL(string: baseUrl.absoluteString + "files.upload")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(appToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"filename\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(filename)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"filetype\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(fileType)\r\n".data(using: .utf8)!)

        if !channels.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"channels\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(channels.joined(separator: ","))\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            logger.debug("Uploading file: \(filename)")

            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                logger.error("File upload failed. Response: \(response)")
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode(FileUploadResponse.self, from: data)
        } catch {
            logger.error("File upload failed: \(error.localizedDescription)")
            throw error
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
    
    struct FileUploadResponse: Decodable {
        /// Response status
        let ok: Bool
        /// File information
        let file: FileInfo?
        /// Optional error if `ok == false`
        let error: String?
    }
    
    struct FileInfo: Decodable {
        let id: String
        let name: String
        let urlPrivate: String
        let urlPrivateDownload: String?
        let permalink: String
        let permalinkPublic: String?
        let filetype: String?
        let size: Int?
    }
    
    enum ClientError: Swift.Error {
        case slackTokenRequired
        case invalidSlackURL
    }
}

