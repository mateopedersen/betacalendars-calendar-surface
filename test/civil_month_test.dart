import 'package:betacalendars_calendar_surface/betacalendars_calendar_surface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CivilMonth', () {
    test('rejects invalid month and year instead of normalizing', () {
      expect(() => CivilMonth(2027, 0), throwsRangeError);
      expect(() => CivilMonth(2027, 13), throwsRangeError);
      expect(() => CivilMonth(0, 1), throwsRangeError);
      expect(() => CivilMonth(10000, 1), throwsRangeError);
    });

    test('moves across year boundaries and checks representable limits', () {
      expect(CivilMonth(2027, 1).previous(), CivilMonth(2026, 12));
      expect(CivilMonth(2026, 12).next(), CivilMonth(2027, 1));
      expect(CivilMonth(2027, 1).addMonths(-13), CivilMonth(2025, 12));
      expect(() => CivilMonth(1, 1).previous(), throwsRangeError);
      expect(() => CivilMonth(9999, 12).next(), throwsRangeError);
    });

    test('uses Gregorian leap-year behavior', () {
      expect(CivilMonth(1900, 2).dayCount, 28);
      expect(CivilMonth(2000, 2).dayCount, 29);
      expect(CivilMonth(2024, 2).dayCount, 29);
      expect(CivilMonth(2027, 2).dayCount, 28);
      expect(CivilMonth(2100, 2).dayCount, 28);
      expect(CivilMonth(2400, 2).dayCount, 29);
    });
  });
}
