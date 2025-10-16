import Foundation

extension Array where Element == BlockConvertible {
    @MainActor
    var json: String {
        """
        \(map { $0.json }.joined(separator: ", "))
        """
    }
}
