import Foundation

public enum SlackLimits {
    public static let blocksPerMessage = 50
    public static let notificationText = 3000

    public static let headerText = 150
    public static let sectionText = 3000
    public static let fieldText = 2000
    public static let fieldsPerSection = 10
    public static let contextElements = 10

    public static let buttonText = 75
    public static let elementsPerActions = 25

    public static let optionText = 75
    public static let optionValue = 75
    public static let optionsPerOverflow = 5
}

public enum SlackMessageError: Error, Equatable {
    case tooManyBlocks(count: Int, limit: Int)
    case emptyMessage
}

extension String {
    func truncated(to limit: Int) -> String {
        guard count > limit else { return self }
        guard limit > 1 else { return String(prefix(limit)) }

        return prefix(limit - 1) + "…"
    }
}
