/// Adaptive, accessible calendar presentation for Flutter.
///
/// Calendar Surface turns date-only month data into responsive month grids,
/// localized day semantics, keyboard-operable date cells, and genuinely
/// undated planning grids. It leaves persistence, events, networking, and
/// timezone conversion to the host application.
///
/// See the [Beta Calendars project](https://www.betacalendars.com/) for the
/// broader calendar-engineering context.
library;

export 'src/layout/calendar_layout_policy.dart';
export 'src/model/blank_calendar_model.dart';
export 'src/model/calendar_month_model.dart';
export 'src/model/civil_month.dart';
export 'src/widgets/adaptive_calendar_surface.dart';
export 'src/widgets/blank_calendar_surface.dart';
export 'src/widgets/calendar_surface.dart';
export 'src/widgets/calendar_surface_theme.dart';
