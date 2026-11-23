import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/features/bookings/domain/booking_request.dart';

/// Page 32's close-out card (client, 23-11-2026). Two things decide what the
/// trainer sees and what the backend then writes, and both are cheap to get
/// wrong silently:
///
/// * the server's `canComplete` / `canCancel` flags, which are the only rule
///   the screen obeys — a missing field must read as "no button", never as
///   one that 400s on tap;
/// * which reason means the client never turned up, because that single flag
///   is the difference between a `NO_SHOW_CUSTOMER` (client charged, trainer
///   not at fault) and a `CANCELLED_BY_TEACHER` (client refunded in full,
///   trainer's earning withheld).
void main() {
  group('BookingDetail close flags', () {
    Map<String, dynamic> json(Map<String, dynamic> extra) => {
      'sessionId': 's1',
      'status': 'ASSIGNED',
      ...extra,
    };

    test('reads both flags from the server', () {
      final detail = BookingDetail.fromJson(
        json({'canComplete': true, 'canCancel': true}),
      );

      expect(detail.canComplete, isTrue);
      expect(detail.canCancel, isTrue);
      expect(detail.canClose, isTrue);
    });

    test('a missing flag hides its button rather than offering a 400', () {
      final detail = BookingDetail.fromJson(json({}));

      expect(detail.canComplete, isFalse);
      expect(detail.canCancel, isFalse);
      expect(detail.canClose, isFalse);
    });

    test('a completed booking offers neither, so the card is gone', () {
      final detail = BookingDetail.fromJson(
        json({'status': 'COMPLETED', 'canComplete': false, 'canCancel': false}),
      );

      expect(detail.canClose, isFalse);
    });

    test('one of the two is enough to show the card', () {
      final detail = BookingDetail.fromJson(json({'canCancel': true}));

      expect(detail.canClose, isTrue);
      expect(detail.canComplete, isFalse);
    });
  });

  group('cancellation reasons', () {
    test('only the first means the client was absent', () {
      expect(isClientAbsent(cancellationReasons.first), isTrue);

      for (final reason in cancellationReasons.skip(1)) {
        expect(isClientAbsent(reason), isFalse, reason: reason);
      }
    });

    test('the absent reason says so in words the trainer will recognise', () {
      expect(cancellationReasons.first, 'Client was not available');
    });

    test('the list ends on the free-text case', () {
      expect(cancellationReasons.last, 'Other reason');
    });
  });
}
