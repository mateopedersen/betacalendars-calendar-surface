import 'package:flutter/widgets.dart';

/// Width policy for weekday labels.
enum WeekdayLabelDensity { auto, full, short, narrow }

/// Layout values derived from real parent constraints and text scale.
final class CalendarLayoutMetrics {
  /// Creates a resolved layout.
  const CalendarLayoutMetrics({
    required this.labelDensity,
    required this.cellExtent,
    required this.maxWidth,
  });

  /// Chosen weekday label density.
  final WeekdayLabelDensity labelDensity;

  /// Preferred minimum row extent, in logical pixels.
  final double cellExtent;

  /// Optional maximum width for the complete surface.
  final double? maxWidth;
}

/// Resolves a calendar layout without classifying the device type.
///
/// Auto labels become shorter as actual width decreases or text scale grows.
/// The user-provided [TextScaler] is honored; this policy never clamps it.
final class CalendarLayoutPolicy {
  /// Creates a policy with optional wide-layout constraints.
  const CalendarLayoutPolicy({
    this.labelDensity = WeekdayLabelDensity.auto,
    this.compactBelow = 420,
    this.narrowBelow = 300,
    this.maxCalendarWidth = 960,
    this.minimumCellExtent = 44,
  });

  /// Explicit or adaptive weekday label density.
  final WeekdayLabelDensity labelDensity;

  /// Width below which auto mode uses short labels.
  final double compactBelow;

  /// Width below which auto mode uses narrow labels.
  final double narrowBelow;

  /// Maximum total calendar width; null leaves it unconstrained.
  final double? maxCalendarWidth;

  /// Minimum desired height for an interactive cell.
  final double minimumCellExtent;

  /// Resolves layout values for [width] and [textScaler].
  CalendarLayoutMetrics resolve({
    required double width,
    required TextScaler textScaler,
  }) {
    final double scale = textScaler.scale(14) / 14;
    final WeekdayLabelDensity resolved = switch (labelDensity) {
      WeekdayLabelDensity.auto when width / scale < narrowBelow =>
        WeekdayLabelDensity.narrow,
      WeekdayLabelDensity.auto when width / scale < compactBelow =>
        WeekdayLabelDensity.short,
      WeekdayLabelDensity.auto => WeekdayLabelDensity.full,
      _ => labelDensity,
    };
    return CalendarLayoutMetrics(
      labelDensity: resolved,
      cellExtent: minimumCellExtent * (scale > 1.35 ? 1.2 : 1),
      maxWidth: maxCalendarWidth,
    );
  }
}
