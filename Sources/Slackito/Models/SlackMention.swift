import Foundation

public enum SlackMentionType {
    /// User mentions are usernames, e.g. `@Tim` becomes `<@Tim>`
    case user(String)
    /// Group/alias mentions are ids, e.g. `@release-on-duty-..` becomes `<!subteam^C04SLA040...>`
    case subgroup(String)

    public var mention: String {
        switch self {
            case .user(let user):
                return "<@\(user)>"
            case .subgroup(let subgroup):
                return "<!subteam^\(subgroup)>"
        }
    }
}
