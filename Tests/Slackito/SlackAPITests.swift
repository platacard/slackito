import XCTest
@testable import Slackito

@MainActor
final class SlackitoTests: XCTestCase {
    
    func test_BlockBuilderProducesRawJson() throws {
        let message = SlackMessage(channel: "test_channel") {
            Divider()
        }
        
        let expected = """
        { "channel": "test_channel", "blocks": [ { "type": "divider" } ] }
        """
        let actual = message.json
        
        XCTAssertEqual(expected, actual)
    }
    
    func test_BlockBuilderWithHeaderProducesRawJson() throws {
        let message = SlackMessage(channel: "test_channel") {
            Header("Test header")
        }
        
        let expected = """
        { "channel": "test_channel", "blocks": [ { "type": "header", "text": { "type": "plain_text", "text": "Test header" } } ] }
        """
        
        let actual = message.json
        XCTAssertEqual(expected, actual)
    }
    
    func test_BlockBuilderWithHeaderProducesPrettyJson() throws {
        let message = SlackMessage(channel: "test_channel") {
            Header("Test header")
        }
        
        let expected = """
        {
          "channel" : "test_channel",
          "blocks" : [
            {
              "type" : "header",
              "text" : {
                "type" : "plain_text",
                "text" : "Test header"
              }
            }
          ]
        }
        """
        
        let actual = try message.json.prettify()
        XCTAssertEqual(expected, actual)
    }
    
    func test_BlockBuilderAndStringExtensionProducesPrettyJson() throws {
        let message = SlackMessage(channel: "test_channel") {
            Divider()
        }
        
        let expected = """
        {
          "channel" : "test_channel",
          "blocks" : [
            {
              "type" : "divider"
            }
          ]
        }
        """
        let actual = try message.json.prettify()
        
        XCTAssertEqual(expected, actual)
    }
    
    func test_SectionBuilderProducesCorrectRawJson() throws {
        let message = SlackMessage(channel: "test_channel") {
            FieldsSection {
                MarkdownSection("test")
                MarkdownSection("test")
            }
        }
        
        let expected = """
        { "channel": "test_channel", "blocks": [ { "type": "section", "fields": [ { "type": "mrkdwn", "text": "test" }, { "type": "mrkdwn", "text": "test" } ] } ] }
        """
        
        let actual = message.json
        XCTAssertEqual(expected, actual)
    }
    
    func test_SectionBuilderProducesCorrectPrettyJson() throws {
        let message = SlackMessage(channel: "test_channel") {
            FieldsSection {
                MarkdownSection("test1")
                MarkdownSection("test2")
            }
        }
        
        let expected = """
        {
          "channel" : "test_channel",
          "blocks" : [
            {
              "type" : "section",
              "fields" : [
                {
                  "type" : "mrkdwn",
                  "text" : "test1"
                },
                {
                  "type" : "mrkdwn",
                  "text" : "test2"
                }
              ]
            }
          ]
        }
        """
        
        let actual = try message.json.prettify()
        XCTAssertEqual(expected, actual)
    }
    
    func test_ContextBuilderProducesCorrectRawJson() throws {
        let message = SlackMessage(channel: "test_channel") {
            Context {
                "test1"
                "test2"
            }
        }
        
        let expected = """
        { "channel": "test_channel", "blocks": [ { "type": "context", "elements": [ { "type": "mrkdwn", "text": "test1" }, { "type": "mrkdwn", "text": "test2" } ] } ] }
        """
        
        let actual = message.json
        XCTAssertEqual(expected, actual)
    }
    
    func test_ContextBuilderProducesCorrectPrettyJson() throws {
        let message = SlackMessage(channel: "test_channel") {
            Context {
                "test1"
                "test2"
            }
        }
        
        let expected = """
        {
          "channel" : "test_channel",
          "blocks" : [
            {
              "type" : "context",
              "elements" : [
                {
                  "type" : "mrkdwn",
                  "text" : "test1"
                },
                {
                  "type" : "mrkdwn",
                  "text" : "test2"
                }
              ]
            }
          ]
        }
        """
        
        let actual = try message.json.prettify()
        XCTAssertEqual(expected, actual)
    }
    
    func test_ComplexMessageBuilderProducesCorrectPrettyJson() throws {
        let message = SlackMessage(channel: "test_channel", ts: "test_thread") {
            PlainSection("plain_text")
            MarkdownSection("markdown_text")
            FieldsSection {
                "field1"
                "field2"
            }
            Context {
                "context1"
                "context2"
            }
        }
        
        let expected = """
        {
          "thread_ts" : "test_thread",
          "ts" : "test_thread",
          "channel" : "test_channel",
          "blocks" : [
            {
              "type" : "section",
              "text" : {
                "type" : "plain_text",
                "text" : "plain_text"
              }
            },
            {
              "type" : "section",
              "text" : {
                "type" : "mrkdwn",
                "text" : "markdown_text"
              }
            },
            {
              "type" : "section",
              "fields" : [
                {
                  "type" : "mrkdwn",
                  "text" : "field1"
                },
                {
                  "type" : "mrkdwn",
                  "text" : "field2"
                }
              ]
            },
            {
              "type" : "context",
              "elements" : [
                {
                  "type" : "mrkdwn",
                  "text" : "context1"
                },
                {
                  "type" : "mrkdwn",
                  "text" : "context2"
                }
              ]
            }
          ]
        }
        """
        
        let actual = try message.json.prettify()
        XCTAssertEqual(expected, actual)
    }
}
