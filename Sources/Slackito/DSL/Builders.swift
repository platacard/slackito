import Foundation

@resultBuilder
public enum SlackMessageBuilder {
    public typealias Expression = BlockConvertible
    public typealias Component = [BlockConvertible]
    
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }
    
    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }
    
    public static func buildBlock(_ channel: String, thread: String?, components: Component...) -> (String, String?, [Component]) {
        (channel, thread, components.compactMap { $0 })
    }
    
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }
    
    public static func buildEither(first component: Component) -> Component {
        component
    }
    
    public static func buildEither(second component: Component) -> Component {
        component
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }
}

@resultBuilder
public enum SlackMessagePlainSectionBuilder {
    public typealias Expression = PlainSectionConvertible
    public typealias Component = [PlainSectionConvertible]
    
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }
    
    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }
    
    public static func buildEither(first component: Component) -> Component {
        component
    }
    
    public static func buildEither(second component: Component) -> Component {
        component
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }
}

@resultBuilder
public enum SlackMessageMarkdownSectionBuilder {
    public typealias Expression = MarkdownSectionConvertible
    public typealias Component = [MarkdownSectionConvertible]
    
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }
    
    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }
    
    public static func buildEither(first component: Component) -> Component {
        component
    }
    
    public static func buildEither(second component: Component) -> Component {
        component
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }
}
