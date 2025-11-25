/// 🏋️‍♂️ GymBro TrackLog - Simple Markdown Parser
///
/// 📁 Layer: shared/utils
/// 🎯 Purpose: Parse basic markdown (bold, italic) without heavy dependencies
/// 🔧 Type: utility
///
/// Supports:
/// - **bold** → bold text
/// - *italic* → italic text
/// - _italic_ → italic text (alternative)
/// - `code` → monospace text
///
/// Usage:
/// ```dart
/// SimpleMarkdownParser.buildText(
///   '**Bold** and *italic* text',
///   style: TextStyle(color: Colors.black),
///   context: context,
/// )
/// ```
library;

import 'package:flutter/material.dart';

/// Simple markdown parser for basic formatting
class SimpleMarkdownParser {
  SimpleMarkdownParser._();

  /// Build a RichText widget from markdown string
  ///
  /// Supports: **bold**, *italic*, _italic_, `code`
  static Widget buildText(
    String text, {
    required TextStyle? baseStyle,
    TextAlign textAlign = TextAlign.start,
  }) {
    final spans = _parseMarkdown(text, baseStyle);

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign,
    );
  }

  /// Parse markdown string into TextSpans
  static List<InlineSpan> _parseMarkdown(String text, TextStyle? baseStyle) {
    final List<InlineSpan> spans = [];
    final effectiveStyle = baseStyle ?? const TextStyle();

    // Pattern to match: **bold**, *italic*, _italic_, `code`
    // Order matters: ** before * to avoid conflicts
    final pattern = RegExp(
      r'(\*\*(.+?)\*\*)|' // **bold**
      r'(\*(.+?)\*)|'     // *italic*
      r'(_(.+?)_)|'       // _italic_
      r'(`(.+?)`)',       // `code`
    );

    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      // Add plain text before match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: effectiveStyle,
        ));
      }

      // Determine which group matched
      if (match.group(1) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(2),
          style: effectiveStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(3) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(4),
          style: effectiveStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(5) != null) {
        // _italic_
        spans.add(TextSpan(
          text: match.group(6),
          style: effectiveStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(7) != null) {
        // `code`
        spans.add(TextSpan(
          text: match.group(8),
          style: effectiveStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: effectiveStyle.color?.withValues(alpha: 0.1),
          ),
        ));
      }

      lastEnd = match.end;
    }

    // Add remaining plain text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: effectiveStyle,
      ));
    }

    // If no spans were created, return the original text
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: effectiveStyle));
    }

    return spans;
  }

  /// Check if text contains any markdown formatting
  static bool containsMarkdown(String text) {
    return text.contains('**') ||
        text.contains('*') ||
        text.contains('_') ||
        text.contains('`');
  }
}
