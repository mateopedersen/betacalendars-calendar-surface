import 'package:betacalendars_calendar_surface/betacalendars_calendar_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the selected January month consistently', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorSchemeSeed: const Color(0xFF356859)),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: CalendarSurface(
                model: CalendarMonthModel(
                  month: CivilMonth(2027, 1),
                  adjacentDays: AdjacentDayMode.hide,
                ),
                selectedDate: DateTime.utc(2027, 1, 15),
                onDayActivated: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(CalendarSurface),
      matchesGoldenFile('goldens/calendar_surface.png'),
    );
  });
}
