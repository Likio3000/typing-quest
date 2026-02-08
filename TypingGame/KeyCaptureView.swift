import SwiftUI

enum KeyInput {
    case character(Character)
    case backspace
}

struct KeyCaptureView: NSViewRepresentable {
    var onInput: (KeyInput) -> Void

    func makeNSView(context: Context) -> KeyCaptureNSView {
        let view = KeyCaptureNSView()
        view.onInput = onInput
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: KeyCaptureNSView, context: Context) {
        nsView.onInput = onInput
        nsView.ensureFirstResponderIfNeeded()
    }
}

final class KeyCaptureNSView: NSView {
    var onInput: ((KeyInput) -> Void)?

    override func isAccessibilityElement() -> Bool {
        false
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Let underlying SwiftUI controls receive mouse and scroll events.
        nil
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    func ensureFirstResponderIfNeeded() {
        guard let window = window, window.isKeyWindow else { return }
        guard window.firstResponder !== self else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window, window.isKeyWindow else { return }
            window.makeFirstResponder(self)
        }
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        super.mouseDown(with: event)
    }

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) || event.modifierFlags.contains(.control) {
            return
        }

        if event.keyCode == 51 {
            onInput?(.backspace)
            return
        }

        if event.keyCode == 36 || event.keyCode == 76 {
            onInput?(.character("\n"))
            return
        }

        guard let characters = event.characters, let first = characters.first else {
            return
        }

        if first == "\u{7F}" {
            onInput?(.backspace)
            return
        }

        if first == "\r" || first == "\u{3}" {
            onInput?(.character("\n"))
            return
        }

        onInput?(.character(first))
    }
}
