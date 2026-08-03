import Foundation

extension String {
    func truncated(to limit: Int) -> String {
        guard limit > 0 else { return "" }
        guard unicodeScalars.count > limit else { return self }

        var budget = limit - 1
        var kept = ""

        for character in self {
            let width = character.unicodeScalars.count
            guard width <= budget else { break }
            kept.append(character)
            budget -= width
        }

        return kept + "…"
    }
}
