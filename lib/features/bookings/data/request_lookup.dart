import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/booking_request.dart';
import 'bookings_providers.dart';

/// One request out of the inbox, by id — what pages 33 and 34 are about.
///
/// Reads the list rather than fetching a single request, because there is no
/// `GET /requests/:id` and there does not need to be: both screens are
/// reached from page 31 or 32, so the list is already in the cache.
///
/// Null while the list is still loading, and null again the moment an answer
/// is sent and the inbox is invalidated — which is why pages 33 and 34 keep
/// their own copy once they have one.
final requestByIdProvider = Provider.family<BookingRequest?, String>((
  ref,
  requestId,
) {
  final rows = ref.watch(bookingRequestsProvider).value ?? const [];
  final match = rows.where((row) => row.id == requestId);

  return match.isEmpty ? null : match.first;
});
