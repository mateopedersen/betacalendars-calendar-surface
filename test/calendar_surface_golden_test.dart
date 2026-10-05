import 'dart:io';
import 'dart:typed_data';

import 'package:betacalendars_calendar_surface/betacalendars_calendar_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the selected January month consistently', (
    WidgetTester tester,
  ) async {
    final GoldenFileComparator originalComparator = goldenFileComparator;
    goldenFileComparator = _CrossPlatformGoldenComparator(originalComparator);
    addTearDown(() => goldenFileComparator = originalComparator);

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

/// Allows tiny rasterization differences between host operating systems.
final class _CrossPlatformGoldenComparator implements GoldenFileComparator {
  _CrossPlatformGoldenComparator(this._delegate);

  static const double _maximumDiffPercent = 1.5;

  final GoldenFileComparator _delegate;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final Uri resolvedGolden = _delegate.getTestUri(golden, null);
    final String path = 'test/${resolvedGolden.path}';
    final List<int> goldenBytes = await File(path).readAsBytes();
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      goldenBytes,
    );
    final bool withinTolerance =
        result.passed || result.diffPercent <= _maximumDiffPercent;
    result.dispose();
    if (withinTolerance) return true;
    return _delegate.compare(imageBytes, golden);
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) =>
      _delegate.update(golden, imageBytes);

  @override
  Uri getTestUri(Uri key, int? version) => _delegate.getTestUri(key, version);
}
