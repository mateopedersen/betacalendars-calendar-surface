import 'package:betacalendars_calendar_surface/betacalendars_calendar_surface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cross-year fixtures have expected calendar boundaries', () {
    expect(CivilMonth(2026, 11).dayCount, 30);
    expect(CivilMonth(2026, 11).firstDay.weekday, DateTime.sunday);
    expect(CivilMonth(2026, 12).dayCount, 31);
    expect(CivilMonth(2027, 1).dayCount, 31);
    expect(CivilMonth(2027, 2).dayCount, 28);
  });

  test('every week start produces chronological seven-cell rows', () {
    for (final WeekStart start in WeekStart.values) {
      final CalendarMonthModel model = CalendarMonthModel(
        month: CivilMonth(2027, 1),
        weekStartsOn: start,
      );
      expect(model.rows.every((row) => row.length == 7), isTrue);
      final List<DateTime> current = model.days
          .where((day) => day.isCurrentMonth)
          .map((day) => day.date!)
          .toList();
      expect(current.length, 31);
      expect(
        current.map((date) => date.day),
        List<int>.generate(31, (i) => i + 1),
      );
      expect(model.cellCount, inInclusiveRange(28, 42));
    }
  });

  test(
    'fixed grids have 42 cells and adjacent policies preserve structure',
    () {
      final CalendarMonthModel shown = CalendarMonthModel(
        month: CivilMonth(2027, 1),
        gridMode: MonthGridMode.fixedSixWeeks,
        adjacentDays: AdjacentDayMode.show,
      );
      final CalendarMonthModel hidden = CalendarMonthModel(
        month: CivilMonth(2027, 1),
        gridMode: MonthGridMode.fixedSixWeeks,
        adjacentDays: AdjacentDayMode.hide,
      );
      final CalendarMonthModel placeholders = CalendarMonthModel(
        month: CivilMonth(2027, 1),
        gridMode: MonthGridMode.fixedSixWeeks,
        adjacentDays: AdjacentDayMode.placeholder,
      );
      expect(shown.cellCount, 42);
      expect(hidden.cellCount, 42);
      expect(placeholders.cellCount, 42);
      expect(
        shown.days.where((day) => day.relation == MonthRelation.previous),
        isNotEmpty,
      );
      expect(
        hidden.days.where((day) => day.relation == MonthRelation.previous),
        isEmpty,
      );
      expect(placeholders.days.where((day) => day.date == null), isNotEmpty);
    },
  );

  test('all months from 1900 through 2100 preserve model invariants', () {
    for (int year = 1900; year <= 2100; year++) {
      for (int month = 1; month <= 12; month++) {
        for (final WeekStart start in WeekStart.values) {
          final CalendarMonthModel model = CalendarMonthModel(
            month: CivilMonth(year, month),
            weekStartsOn: start,
            gridMode: MonthGridMode.fixedSixWeeks,
          );
          expect(model.cellCount, 42, reason: '$year-$month ${start.name}');
          final List<CalendarDay> days = model.days.toList();
          expect(
            days.map((day) => '${day.row}:${day.column}').toSet().length,
            42,
          );
          final List<DateTime> inMonth = days
              .where((day) => day.isCurrentMonth)
              .map((day) => day.date!)
              .toList();
          expect(inMonth.length, CivilMonth(year, month).dayCount);
          expect(
            inMonth.map((date) => date.day),
            List<int>.generate(CivilMonth(year, month).dayCount, (i) => i + 1),
          );
        }
      }
    }
  });
}
