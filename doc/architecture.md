# Architecture

The package separates three jobs:

1. `CivilMonth` represents a validated Gregorian year and month.
2. `CalendarMonthModel` turns that month and explicit policies into immutable
   date cells and structural rows.
3. `CalendarSurface` and `AdaptiveCalendarSurface` present the model using the
   host app's Flutter theme, localization, text scale, and directionality.

Blank planning canvases use a separate `BlankCalendarModel`; there is no
date-shaped sentinel value. Application selection and persistence remain in the
host app. Runtime code performs no I/O.

## Date-only carrier

Cell dates use `DateTime.utc(year, month, day)` at midnight. This is a stable
way to carry civil fields, not a timezone conversion and not an instant to
display as a local time. Compare year/month/day fields for date identity.

## Adaptive layout

Layout responds to actual width and `MediaQuery.textScalerOf`. Dense weekday
headings are the default; apps with full locale weekday names can provide a
`weekdayLabelBuilder`. The visual `Row` honors `Directionality`, while model
cells remain chronological.
