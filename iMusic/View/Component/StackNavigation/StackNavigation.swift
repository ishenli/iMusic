import SwiftUI
import Combine

public struct StackNavigationView<V: Hashable, Content: View>: View {
    
    private var content: Content
    
    @State private var pushed: [(AnyView?, V?)]
    @State private var popped = [(AnyView?, V?)]()
  
    
    private var canGoBack: Bool { pushed.count > 1 }
    private var canGoForward: Bool { popped.count > 0 }
    private var selection: Binding<V?>?
    
    public var body: some View {
        NavigationView(content: { content })
            .environment(\.push, push)
            .environment(\.StackNavigationPush, pushView)
            .environment(\.currentView, pushed.last?.0)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: goBack, label: {
                        Image(systemName: "chevron.left")
                    })
                    .disabled(!canGoBack)
                    .keyboardShortcut("[", modifiers: .command)
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: goForward, label: {
                        Image(systemName: "chevron.right")
                    })
                    .disabled(!canGoForward)
                    .keyboardShortcut("]", modifiers: .command)
                }
            }
    }
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self._pushed = State(initialValue: [])
    }
    
    public init(selection: Binding<V?>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.selection = selection
        self._pushed = State(initialValue: [(nil, selection.wrappedValue)])
    }
//
//    public func stack<Content: View>(item: Binding<Int?>, @ViewBuilder content: () -> Content) -> some View {
////        let content = content().id(UUID())
////        return transformEnvironment(\.modalView) { modalView in
////            if item.wrappedValue != nil {
////                modalView = ModalView(item: item, content: AnyView(content))
////            }
////            else {
////                modalView = nil
////            }
////        }
//    }
  
    public func pushView(destination: AnyView, tag: Any?) {
      self.push(destination, tag: tag)
    }
    
    private func push(_ content: AnyView, tag: Any?) {
        let view = AnyView(content.id(UUID()))
        
        guard let tag = tag as? V? else { preconditionFailure() }
        pushed.append((view, tag))
        popped.removeAll()
        if let tag = tag {
            selection?.wrappedValue = tag
        }
    }
    
    private func goBack() {
        guard let (content, tag) = pushed.popLast() else { preconditionFailure() }
        popped.append((content, tag))
        if let tag = pushed.last?.1 {
            selection?.wrappedValue = tag
        }
    }
    
    private func goForward() {
        guard let (content, tag) = popped.popLast() else { preconditionFailure() }
        pushed.append((content, tag))
        if let tag = tag {
            selection?.wrappedValue = tag
        }
    }
    
}
