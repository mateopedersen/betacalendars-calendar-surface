import 'package:flutter/widgets.dart';

import '../layout/calendar_layout_policy.dart';
import '../model/calendar_month_model.dart';
import '../model/civil_month.dart';
import 'calendar_surface.dart';

/// A [CalendarSurface] that creates its immutable model and adapts to width.
///
/// Layout decisions use the constraints of this widget, not a phone/tablet/
/// desktop classification. The host's text scaler and directionality remain in
/// effect.
class AdaptiveCalendarSurface extends StatelessWidget {
  /// Creates an adaptive month surface.
  const AdaptiveCalendarSurface({
    super.key,
    required this.month,
    this.weekStartsOn = WeekStart.monday,
    this.gridMode = MonthGridMode.natural,
    this.adjacentDays = AdjacentDayMode.show,
    this.selectedDate,
    this.focusedDate,
    this.today,
    this.onDayActivated,
    this.onFocusedDateChanged,
    this.dayBuilder,
    this.weekdayLabelBuilder,
    this.semanticLabelBuilder,
    this.semanticHeaderLabel,
    this.maxCalendarWidth = 960,
  });

  /// Month to display.
  final CivilMonth month;

  /// First weekday column.
  final WeekStart weekStartsOn;

  /// Natural row count or a fixed 42-cell grid.
  final MonthGridMode gridMode;

  /// How outside-month cells are presented.
  final AdjacentDayMode adjacentDays;

  /// Selected date, if any.
  final DateTime? selectedDate;

  /// Controlled focused date, if any.
  final DateTime? focusedDate;

  /// Deterministic current date, if supplied.
  final DateTime? today;

  /// Activates a real date cell and makes cells keyboard-interactive.
  final ValueChanged<DateTime>? onDayActivated;

  /// Receives the next date focused by keyboard navigation.
  final ValueChanged<DateTime>? onFocusedDateChanged;

  /// Builds a visual day child while the surface retains interaction semantics.
  final CalendarDayBuilder? dayBuilder;

  /// Supplies localized visible weekday labels.
  final CalendarWeekdayLabelBuilder? weekdayLabelBuilder;

  /// Overrides the full date spoken for each day.
  final String Function(BuildContext context, DateTime date)?
  semanticLabelBuilder;

  /// Accessible name for the calendar surface.
  final String? semanticHeaderLabel;

  /// Maximum total width of the month surface.
  final double? maxCalendarWidth;

  @override
  Widget build(BuildContext context) {
    final CalendarMonthModel model = CalendarMonthModel(
      month: month,
      weekStartsOn: weekStartsOn,
      gridMode: gridMode,
      adjacentDays: adjacentDays,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final double available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 700;
        final WeekdayLabelDensity density = available / scale < 300
            ? WeekdayLabelDensity.narrow
            : (available / scale < 420
                  ? WeekdayLabelDensity.short
                  : WeekdayLabelDensity.full);
        return CalendarSurface(
          model: model,
          selectedDate: selectedDate,
          focusedDate: focusedDate,
          today: today,
          onDayActivated: onDayActivated,
          onFocusedDateChanged: onFocusedDateChanged,
          dayBuilder: dayBuilder,
          weekdayLabelBuilder: weekdayLabelBuilder,
          semanticLabelBuilder: semanticLabelBuilder,
          semanticHeaderLabel: semanticHeaderLabel,
          weekdayLabelDensity: density,
          maxCalendarWidth: maxCalendarWidth,
        );
      },
    );
  }
}
