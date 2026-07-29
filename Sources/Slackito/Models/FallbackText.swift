import Foundation

@MainActor
public protocol FallbackTextProviding {
    var fallbackText: String? { get }
}

extension Header: FallbackTextProviding {
    public var fallbackText: String? { header.notificationFallback }
}

extension PlainSection: FallbackTextProviding {
    public var fallbackText: String? { plainText.plainNotificationFallback }
}

extension MarkdownSection: FallbackTextProviding {
    public var fallbackText: String? { markdown.notificationFallback }
}

extension FieldsSection: FallbackTextProviding {
    public var fallbackText: String? {
        sections.lazy.compactMap { $0.markdown.notificationFallback }.first
    }
}

extension Context: FallbackTextProviding {
    public var fallbackText: String? {
        markdownElements.lazy.compactMap { $0.markdown.notificationFallback }.first
    }
}

extension Image: FallbackTextProviding {
    public var fallbackText: String? { text.plainNotificationFallback }
}

extension String {
    var notificationFallback: String? {
        mrkdwnStripped.plainNotificationFallback
    }

    var plainNotificationFallback: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var mrkdwnStripped: String {
        var result = ""
        var linkLabel: String?

        for character in self {
            switch character {
            case "<":
                linkLabel = ""
            case ">" where linkLabel != nil:
                result += linkLabel ?? ""
                linkLabel = nil
            case "|" where linkLabel != nil:
                linkLabel = ""
            case "*", "`":
                continue
            default:
                if linkLabel != nil {
                    linkLabel?.append(character)
                } else {
                    result.append(character)
                }
            }
        }

        return result + (linkLabel ?? "")
    }
}
