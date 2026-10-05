import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../layout/calendar_layout_policy.dart';
import '../model/calendar_month_model.dart';
import 'calendar_surface_theme.dart';

/// Visual state supplied to a custom [CalendarSurface.dayBuilder].
final class CalendarDayState {
  /// Creates an immutable visual state.
  const CalendarDayState({
    required this.isSelected,
    required this.isFocused,
    required this.isToday,
    required this.isInteractive,
  });

  /// Whether the caller marked this date selected.
  final bool isSelected;

  /// Whether this date currently owns keyboard focus.
  final bool isFocused;

  /// Whether this date equals the explicitly supplied `today` value.
  final bool isToday;

  /// Whether the surface has an activation callback.
  final bool isInteractive;
}

/// Builds the visual child for one calendar cell.
///
/// Gesture, focus, and date semantics remain owned by [CalendarSurface]. The
/// returned child should be visual only; do not add another button or tap
/// handler unless duplicate activation and semantics are intended.
typedef CalendarDayBuilder =
    Widget Function(
      BuildContext context,
      CalendarDay day,
      CalendarDayState state,
    );

/// Builds one visible weekday heading from its Sunday-first localized index.
///
/// Flutter's [MaterialLocalizations] provides narrow labels. Supply this
/// builder when the host application wants full or short localized names.
typedef CalendarWeekdayLabelBuilder =
    String Function(
      BuildContext context,
      int sundayFirstIndex,
      WeekdayLabelDensity density,
    );

/// A localized, accessible presentation of an immutable month model.
///
/// This widget does not fetch, store, or mutate application data. Date values
/// from the model use UTC midnight as date-only carriers. When
/// [onDayActivated] is null, dates are read-only semantic items rather than
/// disabled buttons. The caller can provide deterministic [today] and
/// [selectedDate] values.
class CalendarSurface extends StatefulWidget {
  /// Creates a calendar from an already-built [CalendarMonthModel].
  const CalendarSurface({
    super.key,
    required this.model,
    this.selectedDate,
    this.focusedDate,
    this.today,
    this.onDayActivated,
    this.onFocusedDateChanged,
    this.dayBuilder,
    this.weekdayLabelBuilder,
    this.headerBuilder,
    this.weekdayLabelDensity = WeekdayLabelDensity.auto,
    this.maxCalendarWidth = 960,
    this.minimumCellExtent = 44,
    this.semanticLabelBuilder,
    this.semanticHeaderLabel,
  });

  /// Dates and structural positions for the displayed month.
  final CalendarMonthModel model;

  /// Currently selected civil date.
  final DateTime? selectedDate;

  /// Controlled keyboard-focused civil date.
  final DateTime? focusedDate;

  /// Optional deterministic civil date to identify as today.
  final DateTime? today;

  /// Called when a real date cell is activated.
  final ValueChanged<DateTime>? onDayActivated;

  /// Called when keyboard navigation moves focus to a date.
  final ValueChanged<DateTime>? onFocusedDateChanged;

  /// Optional visual builder. The surface retains focus and semantics control.
  final CalendarDayBuilder? dayBuilder;

  /// Optional localized weekday labels. The index is Sunday=0 through Saturday=6.
  final CalendarWeekdayLabelBuilder? weekdayLabelBuilder;

  /// Optional replacement for the localized month title.
  final Widget Function(BuildContext context, CalendarMonthModel model)?
  headerBuilder;

  /// Full, short, narrow, or width-adaptive weekday labels.
  final WeekdayLabelDensity weekdayLabelDensity;

  /// Maximum width for the calendar, or null to use all available width.
  final double? maxCalendarWidth;

  /// Preferred interactive day-cell height in logical pixels.
  final double minimumCellExtent;

  /// Optional override for each date's localized semantic label.
  final String Function(BuildContext context, DateTime date)?
  semanticLabelBuilder;

  /// Optional accessible label for the calendar as a whole.
  final String? semanticHeaderLabel;

  @override
  State<CalendarSurface> createState() => _CalendarSurfaceState();
}

class _CalendarSurfaceState extends State<CalendarSurface> {
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};
  DateTime? _uncontrolledFocusedDate;

  @override
  void didUpdateWidget(covariant CalendarSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Set<String> valid = widget.model.days
        .where((day) => day.date != null)
        .map((day) => _dateKey(day.date!))
        .toSet();
    for (final String key in _focusNodes.keys.toList()) {
      if (!valid.contains(key)) {
        _focusNodes.remove(key)?.dispose();
      }
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CalendarSurfaceTheme surfaceTheme =
        Theme.of(context).extension<CalendarSurfaceTheme>() ??
        const CalendarSurfaceTheme();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 700;
        final CalendarLayoutMetrics metrics = CalendarLayoutPolicy(
          labelDensity: widget.weekdayLabelDensity,
          maxCalendarWidth: widget.maxCalendarWidth,
          minimumCellExtent: widget.minimumCellExtent,
        ).resolve(width: width, textScaler: textScaler);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: metrics.maxWidth ?? double.infinity,
            ),
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              label:
                  widget.semanticHeaderLabel ??
                  localizations.formatMonthYear(widget.model.month.firstDay),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    widget.headerBuilder?.call(context, widget.model) ??
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            localizations.formatMonthYear(
                              widget.model.month.firstDay,
                            ),
                            style: textTheme.titleLarge,
                          ),
                        ),
                    _buildWeekdays(context, metrics.labelDensity),
                    for (final List<CalendarDay> row in widget.model.rows)
                      SizedBox(
                        height: metrics.cellExtent,
                        child: Row(
                          textDirection: Directionality.of(context),
                          children: <Widget>[
                            for (final CalendarDay day in row)
                              Expanded(
                                child: _buildDay(
                                  context,
                                  day,
                                  localizations,
                                  colors,
                                  textTheme,
                                  surfaceTheme,
                                  textScaler,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekdays(BuildContext context, WeekdayLabelDensity density) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final int start = _sundayFirstIndex(widget.model.weekStartsOn);
    return SizedBox(
      height: 36,
      child: Row(
        textDirection: Directionality.of(context),
        children: <Widget>[
          for (int column = 0; column < 7; column++)
            Expanded(
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    widget.weekdayLabelBuilder?.call(
                          context,
                          (start + column) % 7,
                          density,
                        ) ??
                        localizations.narrowWeekdays[(start + column) % 7],
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDay(
    BuildContext context,
    CalendarDay day,
    MaterialLocalizations localizations,
    ColorScheme colors,
    TextTheme textTheme,
    CalendarSurfaceTheme surfaceTheme,
    TextScaler textScaler,
  ) {
    final DateTime? date = day.date;
    if (date == null) return const SizedBox.expand();

    final bool selected = _sameDate(widget.selectedDate, date);
    final bool isToday = _sameDate(widget.today, date);
    final DateTime? effectiveFocus =
        widget.focusedDate ?? _uncontrolledFocusedDate;
    final bool focused = _sameDate(effectiveFocus, date);
    final bool interactive = widget.onDayActivated != null;
    final CalendarDayState state = CalendarDayState(
      isSelected: selected,
      isFocused: focused,
      isToday: isToday,
      isInteractive: interactive,
    );
    final Widget visual =
        widget.dayBuilder?.call(context, day, state) ??
        _defaultDayVisual(
          context,
          day,
          state,
          colors,
          textTheme,
          surfaceTheme,
          textScaler,
        );
    final String defaultLabel = localizations.formatFullDate(date);
    final String dateLabel =
        widget.semanticLabelBuilder?.call(context, date) ?? defaultLabel;
    final String label = isToday
        ? '$dateLabel, ${localizations.currentDateLabel}'
        : dateLabel;
    final FocusNode focusNode = _focusNodes.putIfAbsent(
      _dateKey(date),
      () => FocusNode(debugLabel: 'Calendar date $label'),
    );
    void activate() {
      focusNode.requestFocus();
      widget.onDayActivated?.call(date);
    }

    return Semantics(
      container: true,
      label: label,
      button: interactive,
      enabled: interactive ? true : null,
      selected: selected ? true : null,
      focusable: interactive,
      focused: focused,
      onTap: interactive ? activate : null,
      child: Focus(
        focusNode: focusNode,
        canRequestFocus: interactive,
        onKeyEvent: interactive
            ? (FocusNode _, KeyEvent event) => _handleKeyEvent(event, day)
            : null,
        child: ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: interactive ? activate : null,
            child: visual,
          ),
        ),
      ),
    );
  }

  Widget _defaultDayVisual(
    BuildContext context,
    CalendarDay day,
    CalendarDayState state,
    ColorScheme colors,
    TextTheme textTheme,
    CalendarSurfaceTheme surfaceTheme,
    TextScaler textScaler,
  ) {
    final double fontScale = textScaler.scale(14) / 14;
    final bool highContrast = MediaQuery.highContrastOf(context);
    final Color foreground = state.isSelected
        ? (surfaceTheme.selectedForegroundColor ?? colors.onPrimaryContainer)
        : colors.onSurface;
    final Color? background = state.isSelected
        ? (surfaceTheme.selectedBackgroundColor ?? colors.primaryContainer)
        : null;
    final Color? border = state.isFocused
        ? (surfaceTheme.focusedBorderColor ?? colors.primary)
        : (state.isToday
              ? (surfaceTheme.todayBorderColor ?? colors.tertiary)
              : null);
    final double borderWidth = border == null ? 0 : (highContrast ? 2.5 : 1.5);
    final double opacity = day.isCurrentMonth
        ? 1
        : surfaceTheme.outsideMonthOpacity.clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: surfaceTheme.cellPadding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(surfaceTheme.cellRadius),
          border: border == null
              ? null
              : Border.all(color: border, width: borderWidth),
        ),
        child: Center(
          child: Opacity(
            opacity: opacity,
            child: Text(
              '${day.dayNumber}',
              maxLines: 1,
              style: textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontSize:
                    (textTheme.bodyMedium?.fontSize ?? 14) *
                    (fontScale > 1.4 ? 1.1 : 1),
                fontWeight: state.isSelected || state.isToday
                    ? FontWeight.w700
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event, CalendarDay currentDay) {
    if (event is! KeyDownEvent || currentDay.date == null) {
      return KeyEventResult.ignored;
    }
    final DateTime current = currentDay.date!;
    final int directionSign = Directionality.of(context) == TextDirection.rtl
        ? -1
        : 1;
    DateTime? target;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        target = current.add(Duration(days: -directionSign));
      case LogicalKeyboardKey.arrowRight:
        target = current.add(Duration(days: directionSign));
      case LogicalKeyboardKey.arrowUp:
        target = current.subtract(const Duration(days: 7));
      case LogicalKeyboardKey.arrowDown:
        target = current.add(const Duration(days: 7));
      case LogicalKeyboardKey.home:
        target = _startOfWeek(current, widget.model.weekStartsOn);
      case LogicalKeyboardKey.end:
        target = _startOfWeek(
          current,
          widget.model.weekStartsOn,
        ).add(const Duration(days: 6));
      case LogicalKeyboardKey.pageUp:
        target = _shiftDateMonth(current, -1);
      case LogicalKeyboardKey.pageDown:
        target = _shiftDateMonth(current, 1);
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        widget.onDayActivated?.call(current);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
    final DateTime bounded = DateTime.utc(
      target.year.clamp(1, 9999).toInt(),
      target.month,
      target.day,
    );
    final CalendarDay? matchingDay = widget.model.days
        .cast<CalendarDay?>()
        .firstWhere(
          (CalendarDay? candidate) =>
              candidate?.date != null && _sameDate(candidate!.date, bounded),
          orElse: () => null,
        );
    if (matchingDay == null) return KeyEventResult.ignored;
    _uncontrolledFocusedDate = bounded;
    widget.onFocusedDateChanged?.call(bounded);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[_dateKey(bounded)]?.requestFocus();
    });
    setState(() {});
    return KeyEventResult.handled;
  }

  static DateTime _startOfWeek(DateTime date, WeekStart weekStart) {
    final int targetWeekday = switch (weekStart) {
      WeekStart.monday => DateTime.monday,
      WeekStart.tuesday => DateTime.tuesday,
      WeekStart.wednesday => DateTime.wednesday,
      WeekStart.thursday => DateTime.thursday,
      WeekStart.friday => DateTime.friday,
      WeekStart.saturday => DateTime.saturday,
      WeekStart.sunday => DateTime.sunday,
    };
    return date.subtract(Duration(days: (date.weekday - targetWeekday) % 7));
  }

  static DateTime _shiftDateMonth(DateTime date, int delta) {
    final DateTime first = DateTime.utc(date.year, date.month + delta, 1);
    final int lastDay = DateTime.utc(first.year, first.month + 1, 0).day;
    return DateTime.utc(
      first.year,
      first.month,
      date.day.clamp(1, lastDay).toInt(),
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

  static bool _sameDate(DateTime? a, DateTime? b) =>
      a != null &&
      b != null &&
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';
}
