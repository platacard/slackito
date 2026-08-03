import Foundation

@MainActor
protocol DroppedContentReporting {
    var droppedContent: [String] { get }
}

extension FieldsSection: DroppedContentReporting {
    var droppedContent: [String] {
        dropped(sections.count, keeping: SlackLimits.fieldsPerSection, of: "section fields")
    }
}

extension Context: DroppedContentReporting {
    var droppedContent: [String] {
        dropped(markdownElements.count, keeping: SlackLimits.contextElements, of: "context elements")
    }
}

extension Actions: DroppedContentReporting {
    var droppedContent: [String] {
        dropped(buttons.count, keeping: SlackLimits.elementsPerActions, of: "action buttons")
    }
}

extension MarkdownSection: DroppedContentReporting {
    var droppedContent: [String] { accessory?.droppedContent ?? [] }
}

extension PlainSection: DroppedContentReporting {
    var droppedContent: [String] { accessory?.droppedContent ?? [] }
}

extension Accessory {
    var droppedContent: [String] {
        guard case .overflow(let overflow) = self else { return [] }
        return dropped(overflow.options.count, keeping: SlackLimits.optionsPerOverflow, of: "overflow options")
    }
}

private func dropped(_ count: Int, keeping limit: Int, of name: String) -> [String] {
    guard count > limit else { return [] }
    return ["dropped \(count - limit) of \(count) \(name): Slack accepts at most \(limit)"]
}
