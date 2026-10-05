# Accessibility behavior

Each dated cell receives a localized full-date label from Flutter's
`MaterialLocalizations`. Callers can replace that label when their app has a
different localization system. Adjacent cells hidden by policy are structural
empty slots, not screen-reader dates. When activation is absent, dates do not
become disabled buttons.

Interactive cells support focus, arrows, Home/End, Page Up/Page Down, Enter,
and Space. LTR/RTL directionality changes visual left/right movement but never
reorders model data. A caller-controlled `focusedDate` should be updated from
`onFocusedDateChanged` to keep selected app state synchronized.

The surface prefers 44 logical pixels of row height for interactive cells and
honors the host text scaler. A narrow parent still divides available width
among seven columns. Check touch target size, text contrast, and screen reader
behavior in the actual application; this package does not assert WCAG
conformance.
