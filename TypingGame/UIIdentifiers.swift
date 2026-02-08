import Foundation

public enum UIID {
    public static let selectedLevelName = "selected-level-name"
    public static let levelRegenerate = "level-regenerate"
    public static let handCalibrate = "hand-calibrate"
    public static let handZoomMinus = "hand-zoom-minus"
    public static let handZoomValue = "hand-zoom-value"
    public static let handZoomPlus = "hand-zoom-plus"
    public static let handResetPoints = "hand-reset-points"
    public static let restartLevel = "restart-level"
    public static let summaryPendingValue = "summary-pending-value"
    public static let summaryCorrectValue = "summary-correct-value"
    public static let summaryWrongValue = "summary-wrong-value"
    public static let summaryUncorrectedValue = "summary-uncorrected-value"
    public static let summaryCorrectedValue = "summary-corrected-value"
    public static let summaryCompletionHint = "summary-completion-hint"
    public static let completionPopup = "completion-popup"
    public static let completionPopupScore = "completion-popup-score"
    public static let completionPopupStars = "completion-popup-stars"

    public static func levelRow(_ id: String) -> String {
        "level-row-\(id)"
    }

    public static func levelBestScore(_ id: String) -> String {
        "level-best-score-\(id)"
    }

    public static func handPoint(_ fingerRaw: String) -> String {
        "hand-point-\(fingerRaw)"
    }

    public static let handPointLeftIndex = "hand-point-leftIndex"
}
