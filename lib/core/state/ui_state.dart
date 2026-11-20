import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One piece of screen state a widget sets and other providers watch — which
/// chip is lit, what is in a search box.
///
/// Riverpod 3 moved `StateProvider` to `legacy.dart`; a one-field [Notifier]
/// is its replacement, and this is that notifier written once instead of once
/// per filter.
///
/// ```dart
/// final bookingFilterProvider =
///     NotifierProvider<UiState<BookingFilter>, BookingFilter>(
///       () => UiState(BookingFilter.all),
///     );
/// ```
class UiState<T> extends Notifier<T> {
  UiState(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}
