import AppKit
import SwiftUI

struct TargetTextScrollView: NSViewRepresentable {
    var attributedText: NSAttributedString
    var scrollIndex: Int

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSScrollView {
        let textView = TargetTextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 0, height: 6)
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainer?.lineBreakMode = .byCharWrapping
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false

        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        update(textView: textView, context: context)
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        update(textView: textView, context: context)
    }

    private func update(textView: NSTextView, context: Context) {
        textView.textStorage?.setAttributedString(attributedText)

        let length = attributedText.length
        guard length > 0 else { return }

        let caretIndex = max(0, min(scrollIndex, length))
        let previousIndex = max(0, min(caretIndex - 1, length - 1))
        let lastIndex = context.coordinator.lastScrollIndex
        context.coordinator.lastScrollIndex = caretIndex

        guard let lastIndex, caretIndex > lastIndex else { return }

        if let container = textView.textContainer,
           let layoutManager = textView.layoutManager {
            layoutManager.ensureLayout(for: container)

            let safeCaretIndex = min(caretIndex, length - 1)
            let caretGlyph = layoutManager.glyphIndexForCharacter(at: safeCaretIndex)
            let prevGlyph = layoutManager.glyphIndexForCharacter(at: previousIndex)
            let caretRect = layoutManager.lineFragmentRect(
                forGlyphAt: caretGlyph,
                effectiveRange: nil,
                withoutAdditionalLayout: true
            )
            let prevRect = layoutManager.lineFragmentRect(
                forGlyphAt: prevGlyph,
                effectiveRange: nil,
                withoutAdditionalLayout: true
            )

            // Only auto-scroll when typing moves to a new line.
            if abs(caretRect.minY - prevRect.minY) > 0.5,
               let scrollView = textView.enclosingScrollView {
                let containerOrigin = textView.textContainerOrigin
                let caretRectInView = caretRect.offsetBy(dx: containerOrigin.x, dy: containerOrigin.y)
                let visibleHeight = scrollView.contentView.bounds.height
                let maxOriginY = max(0, textView.bounds.height - visibleHeight)
                let targetOriginY = caretRectInView.midY - (visibleHeight / 2)
                let clampedOriginY = min(max(0, targetOriginY), maxOriginY)
                scrollView.contentView.setBoundsOrigin(NSPoint(x: 0, y: clampedOriginY))
                scrollView.reflectScrolledClipView(scrollView.contentView)
            }
        }
    }

    final class Coordinator {
        var lastScrollIndex: Int?
    }
}

private final class TargetTextView: NSTextView {
    override var acceptsFirstResponder: Bool {
        false
    }
}
