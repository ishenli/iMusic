//
//  Popover.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/11.
//

import SwiftUI

struct Popover: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}


struct NSPopoverHolderView<T: View>: NSViewRepresentable {
    @Binding var isVisible: Bool
    var content: () -> T

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.setVisible(isVisible, in: nsView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(state: _isVisible, content: content)
    }

    class Coordinator: NSObject, NSPopoverDelegate {
        private let popover: NSPopover
        private let state: Binding<Bool>

        init<V: View>(state: Binding<Bool>, content: @escaping () -> V) {
            self.popover = NSPopover()
            self.state = state

            super.init()

            popover.delegate = self
            popover.contentViewController = NSHostingController(rootView: content())
            popover.behavior = .transient
        }

        func setVisible(_ isVisible: Bool, in view: NSView) {
            if isVisible {
                popover.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
            } else {
                popover.close()
            }
        }

        func popoverDidClose(_ notification: Notification) {
            self.state.wrappedValue = false
        }

        func popoverShouldDetach(_ popover: NSPopover) -> Bool {
            true
        }
    }
}

struct Popover_Previews: PreviewProvider {
    static var previews: some View {
        Popover()
    }
}
