import Foundation

public extension String {
    func prettify() throws -> String {
        let json = try JSONSerialization.jsonObject(with: data(using: .utf8)!)
        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Error 1", code: 1)
        }
        
        return jsonString
    }
}

extension String: PlainSectionConvertible {
    public var plainText: String { self }
}

extension String: MarkdownSectionConvertible {
    public var markdown: String { self }
}
