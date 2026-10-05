import 'package:betacalendars_calendar_surface/betacalendars_calendar_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders localized month title and full date semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarSurface(
          model: CalendarMonthModel(month: CivilMonth(2027, 1)),
        ),
      ),
    );
    expect(find.text('January 2027'), findsOneWidget);
    final SemanticsNode day = tester.getSemantics(find.text('1').first);
    expect(day.label, contains('January 1, 2027'));
  });

  testWidgets('tap activates a date and exposes selected state', (
    WidgetTester tester,
  ) async {
    DateTime? activated;
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarSurface(
          model: CalendarMonthModel(
            month: CivilMonth(2027, 1),
            adjacentDays: AdjacentDayMode.hide,
          ),
          onDayActivated: (DateTime date) => activated = date,
          selectedDate: DateTime.utc(2027, 1, 1),
        ),
      ),
    );
    await tester.tap(find.text('1'));
    expect(activated, DateTime.utc(2027, 1, 1));
    final Finder day = find.bySemanticsLabel('Friday, January 1, 2027');
    expect(day, findsOneWidget);
    expect(tester.getSemantics(day).flagsCollection.isButton, isTrue);
    expect(
      tester.getSemantics(day).flagsCollection.isSelected.toString(),
      contains('isTrue'),
    );
  });

  testWidgets('adapts across constrained widths, large text, and RTL', (
    WidgetTester tester,
  ) async {
    for (final double width in <double>[240, 280, 320, 360, 400]) {
      for (final double scale in <double>[1, 1.3, 1.5, 2, 2.5, 3]) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  width: width,
                  child: AdaptiveCalendarSurface(month: CivilMonth(2027, 2)),
                ),
              ),
            ),
          ),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'width=$width textScale=$scale',
        );
      }
    }
    expect(find.text('February 2027'), findsOneWidget);
  });

  testWidgets('arrow keys move focus chronologically', (
    WidgetTester tester,
  ) async {
    DateTime? focused;
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarSurface(
          model: CalendarMonthModel(
            month: CivilMonth(2027, 1),
            adjacentDays: AdjacentDayMode.hide,
          ),
          onDayActivated: (_) {},
          onFocusedDateChanged: (DateTime date) => focused = date,
        ),
      ),
    );
    await tester.tap(find.text('1'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(focused, DateTime.utc(2027, 1, 2));
  });

  testWidgets('blank surface has structural cells and no fabricated date', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BlankCalendarSurface(rows: 6, showWeekdayHeader: false),
      ),
    );
    expect(find.text('Blank calendar grid'), findsNothing);
    expect(tester.takeException(), isNull);
    final BlankCalendarModel model = BlankCalendarModel(rows: 6);
    expect(model.cells.length, 42);
  });
}
