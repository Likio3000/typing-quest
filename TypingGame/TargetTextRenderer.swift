import AppKit

struct TargetTextColors {
    let text: NSColor
    let correctBackground: NSColor
    let wrongBackground: NSColor
    let caretBackground: NSColor
    let caretText: NSColor
    let caretIndicator: NSColor
}

final class TargetTextRenderer: ObservableObject {
    private var cachedText = NSMutableAttributedString()
    private var lastTargetText = ""
    private var lastFontSize: Double = 0
    private var lastTypedText = ""
    private var lastCaretIndex = 0
    private var hasCaretIndicator = false

    func render(
        targetText: String,
        typedText: String,
        fontSize: Double,
        colors: TargetTextColors
    ) -> NSAttributedString {
        let targetChanged = targetText != lastTargetText || fontSize != lastFontSize
        let isPrefix = typedText.hasPrefix(lastTypedText)
        let needsRebuild = targetChanged || !isPrefix

        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let targetChars = Array(targetText)
        let typedChars = Array(typedText)
        let caretIndex = typedChars.count

        if needsRebuild {
            rebuildCache(
                targetText: targetText,
                targetChars: targetChars,
                typedChars: typedChars,
                caretIndex: caretIndex,
                font: font,
                colors: colors
            )
            return cachedText
        }

        if typedChars.count == lastTypedText.count + 1 {
            let newIndex = typedChars.count - 1
            applyAttributes(
                at: newIndex,
                targetChars: targetChars,
                typedChars: typedChars,
                caretIndex: caretIndex,
                font: font,
                colors: colors
            )

            if lastCaretIndex != newIndex, lastCaretIndex < targetChars.count {
                applyAttributes(
                    at: lastCaretIndex,
                    targetChars: targetChars,
                    typedChars: typedChars,
                    caretIndex: caretIndex,
                    font: font,
                    colors: colors
                )
            }

            if caretIndex < targetChars.count {
                applyAttributes(
                    at: caretIndex,
                    targetChars: targetChars,
                    typedChars: typedChars,
                    caretIndex: caretIndex,
                    font: font,
                    colors: colors
                )
            }
        } else if typedChars.count != lastTypedText.count {
            rebuildCache(
                targetText: targetText,
                targetChars: targetChars,
                typedChars: typedChars,
                caretIndex: caretIndex,
                font: font,
                colors: colors
            )
            return cachedText
        } else if lastCaretIndex != caretIndex {
            if lastCaretIndex < targetChars.count {
                applyAttributes(
                    at: lastCaretIndex,
                    targetChars: targetChars,
                    typedChars: typedChars,
                    caretIndex: caretIndex,
                    font: font,
                    colors: colors
                )
            }
            if caretIndex < targetChars.count {
                applyAttributes(
                    at: caretIndex,
                    targetChars: targetChars,
                    typedChars: typedChars,
                    caretIndex: caretIndex,
                    font: font,
                    colors: colors
                )
            }
        }

        updateCaretIndicator(
            targetLength: targetChars.count,
            caretIndex: caretIndex,
            font: font,
            colors: colors
        )

        lastTypedText = typedText
        lastCaretIndex = caretIndex
        return cachedText
    }

    private func rebuildCache(
        targetText: String,
        targetChars: [Character],
        typedChars: [Character],
        caretIndex: Int,
        font: NSFont,
        colors: TargetTextColors
    ) {
        cachedText = NSMutableAttributedString(
            string: targetText,
            attributes: [
                .font: font,
                .foregroundColor: colors.text
            ]
        )

        for index in 0..<targetChars.count {
            applyAttributes(
                at: index,
                targetChars: targetChars,
                typedChars: typedChars,
                caretIndex: caretIndex,
                font: font,
                colors: colors
            )
        }

        hasCaretIndicator = false
        updateCaretIndicator(
            targetLength: targetChars.count,
            caretIndex: caretIndex,
            font: font,
            colors: colors
        )

        lastTargetText = targetText
        lastFontSize = font.pointSize
        lastTypedText = typedChars.isEmpty ? "" : String(typedChars)
        lastCaretIndex = caretIndex
    }

    private func applyAttributes(
        at index: Int,
        targetChars: [Character],
        typedChars: [Character],
        caretIndex: Int,
        font: NSFont,
        colors: TargetTextColors
    ) {
        guard index >= 0, index < targetChars.count else { return }

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: colors.text
        ]

        if index < typedChars.count {
            if typedChars[index] == targetChars[index] {
                attributes[.backgroundColor] = colors.correctBackground
            } else {
                attributes[.backgroundColor] = colors.wrongBackground
            }
        }

        if index == caretIndex {
            attributes[.backgroundColor] = colors.caretBackground
            attributes[.foregroundColor] = colors.caretText
        }

        cachedText.setAttributes(attributes, range: NSRange(location: index, length: 1))
    }

    private func updateCaretIndicator(
        targetLength: Int,
        caretIndex: Int,
        font: NSFont,
        colors: TargetTextColors
    ) {
        if caretIndex >= targetLength {
            let caretAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: colors.caretIndicator
            ]
            if hasCaretIndicator {
                let location = targetLength
                cachedText.setAttributes(caretAttributes, range: NSRange(location: location, length: 1))
            } else {
                cachedText.append(NSAttributedString(string: "|", attributes: caretAttributes))
                hasCaretIndicator = true
            }
        } else if hasCaretIndicator {
            cachedText.deleteCharacters(in: NSRange(location: targetLength, length: 1))
            hasCaretIndicator = false
        }
    }
}
