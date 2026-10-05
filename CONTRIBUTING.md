# Contributing

Contributions should preserve the package's separation between date models and
Flutter presentation. Keep runtime dependencies at the Flutter SDK level unless
a concrete need justifies more.

Before opening a pull request:

1. Format Dart files with `dart format .`.
2. Run `flutter analyze` and `flutter test`.
3. Add model, widget, semantics, or RTL coverage for behavior changes.
4. Update API documentation and `CHANGELOG.md` for user-visible changes.
5. Keep examples deterministic and free of network data.

Please describe the user-facing behavior and include the exact commands run.
