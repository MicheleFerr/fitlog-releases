/// Visual feedback style for interactive elements
///
/// Determines which widget tree to use in InteractiveElement:
/// - **expandingStrip**: Uses ExpandingStripContainer (strip + child)
/// - **scaleOnly**: Wraps child directly with scale animation
/// - **none**: No visual feedback (only haptic if configured)
///
/// This enum is separate from [FeedbackTier] to allow composition:
/// you can have high-tier haptic feedback with minimal visual feedback.
enum VisualFeedbackStyle {
  /// Expanding strip animation (2pt → 4pt on press)
  ///
  /// Uses ExpandingStripContainer widget.
  /// Strip color and child passed via builder pattern.
  ///
  /// Use for: Template cards, featured items, category-based UI
  expandingStrip,

  /// Scale-only animation (no strip)
  ///
  /// Wraps child directly with AnimatedScale.
  /// No layout changes, pure transform.
  ///
  /// Use for: Buttons, simple cards, most interactive elements
  scaleOnly,

  /// No visual feedback
  ///
  /// Child rendered as-is, no animations.
  /// Haptic feedback still triggered if configured.
  ///
  /// Use for: Accessibility reduce motion, minimalist UI, text-only interactions
  none,
}
