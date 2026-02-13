import 'package:flutter/cupertino.dart';

/// Rendering modes for SF Symbols.
enum CNSymbolRenderingMode {
  /// Single-color glyph.
  monochrome,

  /// Hierarchical (shaded) rendering.
  hierarchical,

  /// Uses provided palette colors.
  palette,

  /// Uses built-in multicolor assets.
  multicolor,
}

/// Symbol weight matching UIFont.Weight / UIImage.SymbolWeight.
enum CNSymbolWeight {
  ultraLight,
  thin,
  light,
  regular,
  medium,
  semibold,
  bold,
  heavy,
  black,
}

/// Describes an SF Symbol to render natively.
class CNSymbol {
  /// The SF Symbol name, e.g. `chevron.down`.
  final String name;

  /// Desired point size for the symbol.
  final double size; // point size

  /// Symbol weight (stroke thickness). Defaults to regular.
  final CNSymbolWeight? weight;

  /// Preferred icon color (for monochrome/hierarchical modes).
  final Color? color; // preferred icon color (monochrome/hierarchical)
  /// Palette colors for multi-color/palette modes.
  final List<Color>? paletteColors; // multi-color palette
  /// Optional per-icon rendering mode.
  final CNSymbolRenderingMode? mode; // per-icon rendering mode
  /// Whether to enable the built-in gradient when available.
  final bool? gradient; // prefer built-in gradient when available

  /// Creates a symbol description for native rendering.
  const CNSymbol(
    this.name, {
    this.size = 24.0,
    this.weight,
    this.color,
    this.paletteColors,
    this.mode,
    this.gradient,
  });
}
