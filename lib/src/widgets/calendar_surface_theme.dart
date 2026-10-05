import 'package:flutter/material.dart';

/// Optional theme extension for calendar surface states and spacing.
///
/// Omit this extension to use colors and text styles derived from the host
/// Material [ColorScheme] and [TextTheme].
final class CalendarSurfaceTheme extends ThemeExtension<CalendarSurfaceTheme> {
  /// Creates calendar-specific theme overrides.
  const CalendarSurfaceTheme({
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
    this.todayBorderColor,
    this.focusedBorderColor,
    this.outsideMonthOpacity = 0.62,
    this.cellRadius = 12,
    this.cellPadding = const EdgeInsets.all(4),
  });

  /// Background for the selected day.
  final Color? selectedBackgroundColor;

  /// Foreground for the selected day.
  final Color? selectedForegroundColor;

  /// Border color used to identify today independently of fill color.
  final Color? todayBorderColor;

  /// Border color used for the keyboard-focused date.
  final Color? focusedBorderColor;

  /// Opacity multiplier for visible dates outside the displayed month.
  final double outsideMonthOpacity;

  /// Default rounded radius for day cells.
  final double cellRadius;

  /// Padding within each day cell.
  final EdgeInsetsGeometry cellPadding;

  @override
  CalendarSurfaceTheme copyWith({
    Color? selectedBackgroundColor,
    Color? selectedForegroundColor,
    Color? todayBorderColor,
    Color? focusedBorderColor,
    double? outsideMonthOpacity,
    double? cellRadius,
    EdgeInsetsGeometry? cellPadding,
  }) => CalendarSurfaceTheme(
    selectedBackgroundColor:
        selectedBackgroundColor ?? this.selectedBackgroundColor,
    selectedForegroundColor:
        selectedForegroundColor ?? this.selectedForegroundColor,
    todayBorderColor: todayBorderColor ?? this.todayBorderColor,
    focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
    outsideMonthOpacity: outsideMonthOpacity ?? this.outsideMonthOpacity,
    cellRadius: cellRadius ?? this.cellRadius,
    cellPadding: cellPadding ?? this.cellPadding,
  );

  @override
  CalendarSurfaceTheme lerp(
    covariant ThemeExtension<CalendarSurfaceTheme>? other,
    double t,
  ) {
    if (other is! CalendarSurfaceTheme) return this;
    return CalendarSurfaceTheme(
      selectedBackgroundColor: Color.lerp(
        selectedBackgroundColor,
        other.selectedBackgroundColor,
        t,
      ),
      selectedForegroundColor: Color.lerp(
        selectedForegroundColor,
        other.selectedForegroundColor,
        t,
      ),
      todayBorderColor: Color.lerp(todayBorderColor, other.todayBorderColor, t),
      focusedBorderColor: Color.lerp(
        focusedBorderColor,
        other.focusedBorderColor,
        t,
      ),
      outsideMonthOpacity: _lerpDouble(
        outsideMonthOpacity,
        other.outsideMonthOpacity,
        t,
      ),
      cellRadius: _lerpDouble(cellRadius, other.cellRadius, t),
      cellPadding: EdgeInsetsGeometry.lerp(cellPadding, other.cellPadding, t)!,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
