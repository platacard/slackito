import Foundation

@MainActor
protocol FallbackTextProviding {
    var fallbackText: String? { get }
}

extension Header: FallbackTextProviding {
    var fallbackText: String? { header.isEmpty ? nil : header }
}

extension PlainSection: FallbackTextProviding {
    var fallbackText: String? { plainText.isEmpty ? nil : plainText }
}

extension MarkdownSection: FallbackTextProviding {
    var fallbackText: String? { markdown.isEmpty ? nil : markdown }
}
