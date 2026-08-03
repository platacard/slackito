import Foundation

@MainActor
protocol OmittableBlock {
    var isOmitted: Bool { get }
}

extension Header: OmittableBlock {
    var isOmitted: Bool { header.isEmpty }
}

extension MarkdownSection: OmittableBlock {
    var isOmitted: Bool { markdown.isEmpty }
}

extension PlainSection: OmittableBlock {
    var isOmitted: Bool { plainText.isEmpty }
}

extension FieldsSection: OmittableBlock {
    var isOmitted: Bool { sections.allSatisfy { $0.markdown.isEmpty } }
}

extension Context: OmittableBlock {
    var isOmitted: Bool { markdownElements.allSatisfy { $0.markdown.isEmpty } }
}

extension Actions: OmittableBlock {
    var isOmitted: Bool { buttons.isEmpty }
}

extension Image: OmittableBlock {
    var isOmitted: Bool { url.isEmpty }
}
