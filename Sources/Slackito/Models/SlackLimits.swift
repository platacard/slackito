import Foundation

public enum SlackLimits {
    public static let blocksPerMessage = 50
    public static let notificationText = 4000

    public static let headerText = 150
    public static let sectionText = 3000
    public static let fieldText = 2000
    public static let fieldsPerSection = 10
    public static let contextText = 3000
    public static let contextElements = 10

    public static let buttonText = 75
    public static let elementsPerActions = 25

    public static let optionText = 75
    public static let optionValue = 150
    public static let optionsPerOverflow = 5

    public static let imageTitle = 2000
    public static let imageAltText = 2000
    public static let url = 3000
    public static let actionId = 255
}

public enum SlackMessageError: Error, Equatable, Sendable {
    case tooManyBlocks(count: Int, limit: Int)
    case emptyMessage
}

extension SlackMessageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .tooManyBlocks(let count, let limit):
            "The message has \(count) blocks, but Slack accepts at most \(limit)."
        case .emptyMessage:
            "The message has neither blocks, attachments nor text to send."
        }
    }
}
