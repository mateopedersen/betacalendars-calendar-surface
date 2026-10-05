/// A structural position in an undated planning grid.
///
/// Blank cells intentionally contain no [DateTime] or date-like value.
final class BlankCalendarCell {
  /// Creates a zero-based row and column position.
  const BlankCalendarCell({required this.row, required this.column});

  /// Zero-based row index.
  final int row;

  /// Zero-based column index.
  final int column;
}

/// Immutable structure for a date-free blank calendar grid.
final class BlankCalendarModel {
  /// Creates an undated grid with [rows] and [columns].
  factory BlankCalendarModel({required int rows, int columns = 7}) {
    if (rows < 1 || rows > 12) {
      throw RangeError.range(rows, 1, 12, 'rows');
    }
    if (columns < 1 || columns > 31) {
      throw RangeError.range(columns, 1, 31, 'columns');
    }
    final List<BlankCalendarCell> cells = <BlankCalendarCell>[
      for (int row = 0; row < rows; row++)
        for (int column = 0; column < columns; column++)
          BlankCalendarCell(row: row, column: column),
    ];
    return BlankCalendarModel._(
      rowCount: rows,
      columnCount: columns,
      cells: List<BlankCalendarCell>.unmodifiable(cells),
    );
  }

  const BlankCalendarModel._({
    required this.rowCount,
    required this.columnCount,
    required this.cells,
  });

  /// Number of structural rows.
  final int rowCount;

  /// Number of structural columns.
  final int columnCount;

  /// All blank positions in row-major order.
  final List<BlankCalendarCell> cells;
}
