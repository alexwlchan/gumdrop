//
//  EmbeddedColorWell.swift
//
//  Based on an article by Sarah Reichelt:
//  https://troz.net/post/2020/swiftui_for-mac-extras/
//

import Combine
import Foundation
import SwiftUI

struct EmbeddedColorWell: NSViewRepresentable {
    @Binding var selectedColor: Color
    
    class Coordinator: NSObject {
        var embedded: EmbeddedColorWell
        var subscription: AnyCancellable?

        init(_ embedded: EmbeddedColorWell) {
            self.embedded = embedded
        }
        
        // Observe KVO compliant color property on NSColorWell object.
        // Update the selectedColor property on EmbeddedColorWell as needed.
        func changeColor(colorWell: NSColorWell) {
            subscription = colorWell
                .publisher(for: \.color, options: .new)
                .sink { nsColor in
                    DispatchQueue.main.async {
                        self.embedded.selectedColor = Color(nsColor: nsColor)
                    }
            }
        }
    }
    
    func makeCoordinator() -> EmbeddedColorWell.Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSColorWell {
        let colorWell = NSColorWell(style: .minimal)
        context.coordinator.changeColor(colorWell: colorWell)
        return colorWell
    }
    
    func updateNSView(_ nsView: NSColorWell, context: Context) {
        nsView.color = NSColor(selectedColor)
    }
}
