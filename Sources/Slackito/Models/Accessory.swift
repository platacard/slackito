import Foundation

public struct Overflow: Sendable {

    public struct Option: Sendable {
        public let text: String
        public let url: String?
        public let value: String?

        public init(text: String, url: String? = nil, value: String? = nil) {
            self.text = text
            self.url = url
            self.value = value
        }
    }

    public let options: [Option]
    public let actionId: String?

    public init(options: [Option], actionId: String? = nil) {
        self.options = options
        self.actionId = actionId
    }

    public init(actionId: String? = nil, @SlackMessageOverflowOptionBuilder _ options: () -> [Option]) {
        self.options = options()
        self.actionId = actionId
    }

    var element: String? {
        guard !options.isEmpty else { return nil }

        let rendered = options.enumerated().map { index, option in
            var fields = [
                """
                "text": { "type": "plain_text", "emoji": true, "text": "\(option.text.jsonEscaped)" }
                """,
                #""value": "\#((option.value ?? "option_\(index)").jsonEscaped)""#
            ]
            if let url = option.url, !url.isEmpty {
                fields.append(#""url": "\#(url.jsonEscaped)""#)
            }
            return "{ \(fields.joined(separator: ", ")) }"
        }.joined(separator: ", ")

        var fields = [#""type": "overflow""#]
        if let actionId {
            fields.append(#""action_id": "\#(actionId.jsonEscaped)""#)
        }
        fields.append("\"options\": [ \(rendered) ]")

        return "{ \(fields.joined(separator: ", ")) }"
    }
}

public enum Accessory: Sendable {
    case image(ImageAccessory)
    case button(Button)
    case overflow(Overflow)

    var json: String? {
        switch self {
        case .image(let image):
            #""accessory": \#(image.element)"#
        case .button(let button):
            #""accessory": \#(button.json)"#
        case .overflow(let overflow):
            overflow.element.map { #""accessory": \#($0)"# }
        }
    }
}
