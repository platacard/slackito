import Foundation

extension String {
    var jsonEscaped: String {
        var escaped = String.UnicodeScalarView()
        escaped.reserveCapacity(unicodeScalars.count)

        for scalar in unicodeScalars {
            switch scalar {
            case "\\": escaped.append(contentsOf: #"\\"#.unicodeScalars)
            case "\"": escaped.append(contentsOf: #"\""#.unicodeScalars)
            case "\n": escaped.append(contentsOf: #"\n"#.unicodeScalars)
            case "\r": escaped.append(contentsOf: #"\r"#.unicodeScalars)
            case "\t": escaped.append(contentsOf: #"\t"#.unicodeScalars)
            case "\u{08}": escaped.append(contentsOf: #"\b"#.unicodeScalars)
            case "\u{0C}": escaped.append(contentsOf: #"\f"#.unicodeScalars)
            case let other where other.value < 0x20:
                escaped.append(contentsOf: String(format: #"\u%04x"#, other.value).unicodeScalars)
            case let other:
                escaped.append(other)
            }
        }

        return String(escaped)
    }
}
