import Testing
@testable import Slackito

@Suite("SlackMentionsTests")
struct SlackMentionsTests {
    @Test
    func userMention() async throws {
        let userMention = SlackMentionType.user("bot")
        #expect(userMention.mention == "<@bot>")
    }

    @Test
    func groupMention() async throws {
        let groupMention = SlackMentionType.subgroup("12345")
        #expect(groupMention.mention == "<!subteam^12345>")
    }
}

// MARK: - Tests only

extension SlackMentionType: Equatable {
    public static func == (lhs: SlackMentionType, rhs: SlackMentionType) -> Bool {
        lhs.mention == rhs.mention
    }
}
