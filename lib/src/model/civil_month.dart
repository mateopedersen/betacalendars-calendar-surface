/// A validated year and month in the proleptic Gregorian calendar.
///
/// This value models a civil month rather than an instant. It has no time zone,
/// clock, or locale. Date values produced by this package use UTC midnight as
/// a stable carrier for their year, month, and day fields.
final class CivilMonth implements Comparable<CivilMonth> {
  /// Creates a month. [month] must be in the inclusive range 1–12.
  factory CivilMonth(int year, int month) {
    if (year < 1 || year > 9999) {
      throw RangeError.range(year, 1, 9999, 'year');
    }
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    return CivilMonth._(year, month);
  }

  const CivilMonth._(this.year, this.month);

  /// The Gregorian year, from 1 through 9999.
  final int year;

  /// The month number, from 1 (January) through 12 (December).
  final int month;

  /// The first day, represented at UTC midnight.
  DateTime get firstDay => DateTime.utc(year, month);

  /// The last day, represented at UTC midnight.
  DateTime get lastDay => DateTime.utc(year, month + 1, 0);

  /// The number of civil days in this month.
  int get dayCount => lastDay.day;

  /// Returns this month shifted by [value] months.
  CivilMonth addMonths(int value) {
    final int absoluteMonth = (year - 1) * 12 + month - 1 + value;
    if (absoluteMonth < 0 || absoluteMonth >= 9999 * 12) {
      throw RangeError('Month shift $value moves outside years 1–9999.');
    }
    final int targetYear = absoluteMonth ~/ 12 + 1;
    final int targetMonth = absoluteMonth % 12 + 1;
    return CivilMonth(targetYear, targetMonth);
  }

  /// Returns the following month.
  CivilMonth next() => addMonths(1);

  /// Returns the preceding month.
  CivilMonth previous() => addMonths(-1);

  @override
  int compareTo(CivilMonth other) {
    final int yearOrder = year.compareTo(other.year);
    return yearOrder == 0 ? month.compareTo(other.month) : yearOrder;
  }

  @override
  bool operator ==(Object other) =>
      other is CivilMonth && year == other.year && month == other.month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'CivilMonth($year, $month)';
}
