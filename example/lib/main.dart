import 'package:betacalendars_calendar_surface/betacalendars_calendar_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const CalendarExampleApp());

class CalendarExampleApp extends StatelessWidget {
  const CalendarExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Calendar Surface examples',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    darkTheme: ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const <Locale>[Locale('en', 'US')],
    home: const CalendarExampleHome(),
  );
}

class CalendarExampleHome extends StatefulWidget {
  const CalendarExampleHome({super.key});

  @override
  State<CalendarExampleHome> createState() => _CalendarExampleHomeState();
}

class _CalendarExampleHomeState extends State<CalendarExampleHome> {
  CivilMonth _month = CivilMonth(2026, 11);
  DateTime? _selected;
  DateTime? _focused;
  WeekStart _weekStart = WeekStart.monday;
  MonthGridMode _gridMode = MonthGridMode.natural;
  bool _rtl = false;
  double _textScale = 1;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Surface'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Previous month',
            onPressed: () => setState(() => _month = _month.previous()),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Next month',
            onPressed: () => setState(() => _month = _month.next()),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  DropdownButton<WeekStart>(
                    value: _weekStart,
                    onChanged: (WeekStart? value) {
                      if (value != null) setState(() => _weekStart = value);
                    },
                    items: WeekStart.values
                        .map(
                          (WeekStart value) => DropdownMenuItem<WeekStart>(
                            value: value,
                            child: Text(value.name),
                          ),
                        )
                        .toList(),
                  ),
                  DropdownButton<MonthGridMode>(
                    value: _gridMode,
                    onChanged: (MonthGridMode? value) {
                      if (value != null) setState(() => _gridMode = value);
                    },
                    items: MonthGridMode.values
                        .map(
                          (MonthGridMode value) =>
                              DropdownMenuItem<MonthGridMode>(
                                value: value,
                                child: Text(
                                  value == MonthGridMode.natural
                                      ? 'Natural rows'
                                      : 'Six rows',
                                ),
                              ),
                        )
                        .toList(),
                  ),
                  FilterChip(
                    label: const Text('RTL'),
                    selected: _rtl,
                    onSelected: (bool value) => setState(() => _rtl = value),
                  ),
                  DropdownButton<double>(
                    value: _textScale,
                    onChanged: (double? value) {
                      if (value != null) setState(() => _textScale = value);
                    },
                    items: const <double>[1, 1.5, 2, 2.5]
                        .map(
                          (double value) => DropdownMenuItem<double>(
                            value: value,
                            child: Text('${value}x text'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 0, label: Text('Month')),
                ButtonSegment<int>(value: 1, label: Text('Blank')),
              ],
              selected: <int>{_page},
              onSelectionChanged: (Set<int> value) =>
                  setState(() => _page = value.first),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(_textScale)),
                child: Directionality(
                  textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _page == 0 ? _monthDemo() : _blankDemo(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthDemo() => AdaptiveCalendarSurface(
    month: _month,
    weekStartsOn: _weekStart,
    gridMode: _gridMode,
    adjacentDays: AdjacentDayMode.show,
    selectedDate: _selected,
    focusedDate: _focused,
    today: DateTime.utc(2026, 11, 15),
    onDayActivated: (DateTime date) => setState(() => _selected = date),
    onFocusedDateChanged: (DateTime date) => setState(() => _focused = date),
    weekdayLabelBuilder: (BuildContext context, int index, density) {
      final List<String> labels = density == WeekdayLabelDensity.full
          ? const <String>['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
          : const <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];
      return labels[index];
    },
  );

  Widget _blankDemo() => BlankCalendarSurface(
    rows: _gridMode == MonthGridMode.fixedSixWeeks ? 6 : 5,
    weekStartsOn: _weekStart,
    title: const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text('Undated planner grid'),
    ),
    cellBuilder: (BuildContext context, BlankCalendarCell cell) => DecoratedBox(
      decoration: BoxDecoration(
        color: cell.row.isEven
            ? Theme.of(context).colorScheme.surfaceContainerLow
            : null,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
