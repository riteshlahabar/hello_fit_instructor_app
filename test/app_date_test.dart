import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/core/dates/app_date.dart';

/// Hard rule 4 is a wire-format change, and the dangerous half is the parse.
/// `DateTime.tryParse('18-03-1994')` returns null, so before `parseApiDate`
/// existed the backend flipping to `dd-mm-yyyy` would have dropped every date
/// of birth on the floor without an error anywhere.
void main() {
  group('formatDdMmYyyy', () {
    test('pads the day and the month', () {
      expect(formatDdMmYyyy(DateTime(1994, 3, 8)), '08-03-1994');
    });

    test('adds the clock when asked', () {
      expect(
        formatDdMmYyyyHms(DateTime(2026, 11, 19, 9, 5, 2)),
        '19-11-2026 09:05:02',
      );
    });
  });

  group('parseApiDate', () {
    test('reads the new format', () {
      expect(parseApiDate('18-03-1994'), DateTime(1994, 3, 18));
    });

    test('still reads ISO, because the four surfaces ship separately', () {
      expect(parseApiDate('1994-03-18'), DateTime(1994, 3, 18));
      expect(
        parseApiDate('1994-03-18T00:00:00.000Z')?.toUtc(),
        DateTime.utc(1994, 3, 18),
      );
    });

    test('refuses an impossible day rather than rolling it into March', () {
      expect(parseApiDate('31-02-1991'), isNull);
    });

    test('is null-safe on the many nullable date columns', () {
      expect(parseApiDate(null), isNull);
      expect(parseApiDate(''), isNull);
      expect(parseApiDate('not a date'), isNull);
    });

    test('round-trips what formatDdMmYyyy writes', () {
      final date = DateTime(2026, 11, 19);
      expect(parseApiDate(formatDdMmYyyy(date)), date);
    });
  });
}
