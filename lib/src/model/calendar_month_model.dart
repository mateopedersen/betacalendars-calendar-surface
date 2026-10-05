import 'civil_month.dart';

/// The weekday that occupies the first visual column of a calendar grid.
enum WeekStart {
  /// Sunday-first grid.
  sunday,

  /// Monday-first grid.
  monday,

  /// Tuesday-first grid.
  tuesday,

  /// Wednesday-first grid.
  wednesday,

  /// Thursday-first grid.
  thursday,

  /// Friday-first grid.
  friday,

  /// Saturday-first grid.
  saturday,
}

/// The relationship between a dated grid cell and its displayed month.
enum MonthRelation { previous, current, next }

/// The number of rows in a month grid.
enum MonthGridMode {
  /// Includes only rows needed to show the month.
  natural,

  /// Always produces six rows (42 cells).
  fixedSixWeeks,
}

/// Policy for days that fall outside the displayed month.
enum AdjacentDayMode {
  /// Shows the actual adjacent-month date.
  show,

  /// Keeps the slot but paints and exposes no date.
  hide,

  /// Keeps a structural empty slot with no fabricated date.
  placeholder,
}

/// One dated position in a month surface.
///
/// A placeholder has a null [date] and [relation]. It never represents a made-
/// up date. Coordinates are zero-based and [column] is chronological before
/// visual directionality is applied.
final class CalendarDay {
  /// Creates a dated cell or a structural placeholder.
  const CalendarDay({
    required this.date,
    required this.relation,
    required this.row,
    required this.column,
  });

  /// UTC-midnight civil date, or null for a placeholder.
  final DateTime? date;

  /// Month containing [date], or null for a placeholder.
  final MonthRelation? relation;

  /// Zero-based row in the grid.
  final int row;

  /// Zero-based chronological weekday column.
  final int column;

  /// Whether this cell belongs to the displayed month.
  bool get isCurrentMonth => relation == MonthRelation.current;

  /// The day number, or null for a placeholder.
  int? get dayNumber => date?.day;

  /// The weekday using Dart's Monday=1 through Sunday=7 convention.
  int? get weekday => date?.weekday;

  /// Whether the cell contains a real date.
  bool get hasDate => date != null;
}

/// Immutable dates and structural cells for one displayed month.
final class CalendarMonthModel {
  /// Builds a chronological month grid.
  factory CalendarMonthModel({
    required CivilMonth month,
    WeekStart weekStartsOn = WeekStart.monday,
    MonthGridMode gridMode = MonthGridMode.natural,
    AdjacentDayMode adjacentDays = AdjacentDayMode.show,
  }) {
    final int offset =
        (month.firstDay.weekday - _weekdayNumber(weekStartsOn)) % 7;
    final int naturalRows = (offset + month.dayCount + 6) ~/ 7;
    final int rowCount = gridMode == MonthGridMode.fixedSixWeeks
        ? 6
        : naturalRows;
    final List<CalendarDay> cells = <CalendarDay>[];
    for (int index = 0; index < rowCount * 7; index++) {
      final int row = index ~/ 7;
      final int column = index % 7;
      final int dayOffset = index - offset + 1;
      final DateTime date = DateTime.utc(month.year, month.month, dayOffset);
      final bool current = date.month == month.month && date.year == month.year;
      final bool exposeAdjacent = adjacentDays == AdjacentDayMode.show;
      final bool preserveDate = current || exposeAdjacent;
      final MonthRelation? relation = current
          ? MonthRelation.current
          : (preserveDate
                ? (date.isBefore(month.firstDay)
                      ? MonthRelation.previous
                      : MonthRelation.next)
                : null);
      cells.add(
        CalendarDay(
          date: preserveDate ? date : null,
          relation: relation,
          row: row,
          column: column,
        ),
      );
    }
    return CalendarMonthModel._(
      month: month,
      weekStartsOn: weekStartsOn,
      gridMode: gridMode,
      adjacentDays: adjacentDays,
      rows: List<List<CalendarDay>>.unmodifiable(
        List<List<CalendarDay>>.generate(
          rowCount,
          (int row) =>
              List<CalendarDay>.unmodifiable(cells.skip(row * 7).take(7)),
        ),
      ),
    );
  }

  const CalendarMonthModel._({
    required this.month,
    required this.weekStartsOn,
    required this.gridMode,
    required this.adjacentDays,
    required this.rows,
  });

  /// Month represented by this model.
  final CivilMonth month;

  /// First weekday column.
  final WeekStart weekStartsOn;

  /// Row-count policy used to build this model.
  final MonthGridMode gridMode;

  /// Adjacent-month date policy used to build this model.
  final AdjacentDayMode adjacentDays;

  /// Immutable rows, each containing exactly seven cells.
  final List<List<CalendarDay>> rows;

  /// Flattened immutable cells in chronological row-major order.
  Iterable<CalendarDay> get days => rows.expand((List<CalendarDay> row) => row);

  /// The number of structural cells in the grid.
  int get cellCount => rows.length * 7;

  static int _weekdayNumber(WeekStart start) => switch (start) {
    WeekStart.monday => DateTime.monday,
    WeekStart.tuesday => DateTime.tuesday,
    WeekStart.wednesday => DateTime.wednesday,
    WeekStart.thursday => DateTime.thursday,
    WeekStart.friday => DateTime.friday,
    WeekStart.saturday => DateTime.saturday,
    WeekStart.sunday => DateTime.sunday,
  };
}
