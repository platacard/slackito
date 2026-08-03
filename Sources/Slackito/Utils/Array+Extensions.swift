import Foundation

extension Array where Element == BlockConvertible {
    @MainActor
    var json: String {
        renderable.map { $0.json }.joined(separator: ", ")
    }

    @MainActor
    var renderable: [BlockConvertible] {
        filter { ($0 as? OmittableBlock)?.isOmitted != true }
    }
}
