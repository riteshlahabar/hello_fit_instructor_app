/// Dates are `dd-mm-yyyy` everywhere (client, 19-11-2026 — hard rule 4).
///
/// That covers both directions: what the trainer reads on a screen and what
/// goes on the wire in a request or comes back in a response. A `DateTime` is
/// still a `DateTime` in memory; only its edges are formatted.
///
/// The parse side accepts ISO as well, because the four client surfaces do not
/// ship together and an endpoint that answered ISO yesterday may still do so.
/// `DateTime.tryParse` alone returns **null** on `18-03-1994`, which is how a
/// trainer's date of birth would silently vanish mid-rollout.
library;

String _pad(int value) => value.toString().padLeft(2, '0');

/// `18-03-1994`. What a person reads and what the API is sent.
String formatDdMmYyyy(DateTime date) =>
    '${_pad(date.day)}-${_pad(date.month)}-${date.year.toString().padLeft(4, '0')}';

/// `18-03-1994 14:30:05`. The same day, with the clock.
String formatDdMmYyyyHms(DateTime at) =>
    '${formatDdMmYyyy(at)} ${_pad(at.hour)}:${_pad(at.minute)}:${_pad(at.second)}';

/// Reads a date off the API: `dd-mm-yyyy` first, ISO as the fallback.
///
/// Null for anything else, including an impossible day — `DateTime(1991, 2, 31)`
/// rolls forward into March rather than failing, so the result is read back.
DateTime? parseApiDate(Object? value) {
  if (value is DateTime) return value;
  if (value is! String) return null;

  final text = value.trim();
  if (text.isEmpty) return null;

  final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(text);
  if (match == null) return DateTime.tryParse(text);

  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);

  final parsed = DateTime(year, month, day);
  final roundTrips =
      parsed.year == year && parsed.month == month && parsed.day == day;

  return roundTrips ? parsed : null;
}
