import 'package:flutter/material.dart';

import '../model/blank_calendar_model.dart';
import '../model/calendar_month_model.dart';

/// Builds a visual blank cell. Interaction and cell geometry belong to the
/// surface; returned children should remain visual only.
typedef BlankCalendarCellBuilder =
    Widget Function(BuildContext context, BlankCalendarCell cell);

/// A date-free planning grid with optional weekday headings.
///
/// Unlike a month surface with hidden numbers, this widget's model contains no
/// dates. For a seven-column weekday grid, heading labels are supplied in
/// Sunday-first order and rearranged according to [weekStartsOn].
class BlankCalendarSurface extends StatelessWidget {
  /// Creates an undated blank grid.
  const BlankCalendarSurface({
    super.key,
    this.rows = 5,
    this.columns = 7,
    this.weekStartsOn = WeekStart.monday,
    this.weekdayLabels,
    this.showWeekdayHeader = true,
    this.title,
    this.semanticLabel = 'Blank calendar grid',
    this.cellBuilder,
    this.cellExtent = 56,
  });

  /// Number of blank rows.
  final int rows;

  /// Number of blank columns.
  final int columns;

  /// Week start for arranging seven weekday labels.
  final WeekStart weekStartsOn;

  /// Seven localized labels in Sunday-first order.
  final List<String>? weekdayLabels;

  /// Whether to show the optional weekday heading row.
  final bool showWeekdayHeader;

  /// Optional visible title.
  final Widget? title;

  /// Accessible label for the undated grid.
  final String semanticLabel;

  /// Builds one blank visual cell.
  final BlankCalendarCellBuilder? cellBuilder;

  /// Preferred height of each structural row.
  final double cellExtent;

  @override
  Widget build(BuildContext context) {
    final BlankCalendarModel model = BlankCalendarModel(
      rows: rows,
      columns: columns,
    );
    if (weekdayLabels != null && columns == 7 && weekdayLabels!.length != 7) {
      throw ArgumentError.value(
        weekdayLabels!.length,
        'weekdayLabels.length',
        'Seven labels are required for a seven-column weekday grid.',
      );
    }
    if (!cellExtent.isFinite || cellExtent <= 0) {
      throw RangeError.value(cellExtent, 'cellExtent', 'Must be positive.');
    }
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int start = _sundayFirstIndex(weekStartsOn);
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ?title,
          if (showWeekdayHeader && columns == 7)
            SizedBox(
              height: 36,
              child: Row(
                textDirection: Directionality.of(context),
                children: <Widget>[
                  for (int column = 0; column < columns; column++)
                    Expanded(
                      child: Center(
                        child: ExcludeSemantics(
                          child: Text(
                            weekdayLabels == null
                                ? MaterialLocalizations.of(
                                    context,
                                  ).narrowWeekdays[(start + column) % 7]
                                : weekdayLabels![(start + column) % 7],
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          for (int row = 0; row < model.rowCount; row++)
            SizedBox(
              height: cellExtent,
              child: Row(
                textDirection: Directionality.of(context),
                children: <Widget>[
                  for (int column = 0; column < model.columnCount; column++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child:
                            cellBuilder?.call(
                              context,
                              model.cells[row * model.columnCount + column],
                            ) ??
                            DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colors.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static int _sundayFirstIndex(WeekStart start) => switch (start) {
    WeekStart.sunday => 0,
    WeekStart.monday => 1,
    WeekStart.tuesday => 2,
    WeekStart.wednesday => 3,
    WeekStart.thursday => 4,
    WeekStart.friday => 5,
    WeekStart.saturday => 6,
  };
}
