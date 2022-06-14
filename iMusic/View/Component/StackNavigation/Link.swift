import SwiftUI

public struct SidebarNavigationLink<Label, Destination, V: Hashable> : View where Label : View, Destination : View {
    
    var label: Label
    var destination: Destination
    var tag: V?
    var selection: Binding<V?>?
    
    @Environment(\.push) private var push
    
    public var body: some View {
        if let tag = tag, let selection = selection {
            let binding = Binding<V?>(get: { selection.wrappedValue }, set: { _ in
                push(AnyView(destination), tag)
            })
            
            NavigationLink(destination: CurrentView(defaultView: destination), tag: tag, selection: binding, label: { label })
        }
    }

    public init(destination: Destination, tag: V, selection: Binding<V?>, @ViewBuilder label: () -> Label) where V : Hashable {
        self.label = label()
        self.destination = destination
        self.tag = tag
        self.selection = selection
    }
    
}

extension SidebarNavigationLink where Label == Text {
    
    public init<S>(_ title: S, destination: Destination, tag: V, selection: Binding<V?>) where S : StringProtocol {
        self.label = Text(title)
        self.destination = destination
        self.tag = tag
        self.selection = selection
    }
    
}

public struct StackNavigationLink<Label: View, Destination: View>: View {
    
    private var label: Label
    private var destination: Destination
    private var wrapInButton = false
    
    @Environment(\.StackNavigationPush) private var push
    
    public var body: some View {
        let action = {
            self.push(AnyView(destination), nil)
        }
        
        if wrapInButton {
            Button(action: action, label: { label })
        }
        else {
            label.onTapGesture(perform: action)
        }
    }

    /// Creates an instance that presents `destination`.
    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.destination = destination
    }
    
}

extension StackNavigationLink where Label == Text {
    public init<S>(_ title: S, destination: Destination) where S : StringProtocol {
        self.label = Text(title)
        self.destination = destination
        self.wrapInButton = true
    }
    
}
