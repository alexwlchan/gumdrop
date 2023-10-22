import SwiftUI

/// Only renders of a view for the given period.
///
/// For example:
///
/// ```swift
/// Text("Hello, world!")
///     .limitedRendering(for: .seconds(5))
/// ```
///
/// will only display the text "Hello, world!" for five seconds after the
/// view is initially rendered.
///
/// This is based on code xwritten by Yonat and Charlton Provatas on
/// Stack Overflow, see https://stackoverflow.com/a/74765430/1558022
///
private struct LimitedViewModifier: ViewModifier {
    let delay: DispatchTimeInterval

    func body(content: Content) -> some View {
        _content(content)
            .onAppear {
               DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                   self.shouldRender = false
               }
            }
    }

    @ViewBuilder
    private func _content(_ content: Content) -> some View {
        if shouldRender {
            content
        } else {
            content.hidden()
        }
    }

    @State private var shouldRender = true
}

extension View {
    func onlyRender(for delay: DispatchTimeInterval) -> some View {
        modifier(LimitedViewModifier(delay: delay))
    }
}
