import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';

/// `GET /app/instructor/dashboard` — page 24, one call.
///
/// The API composes the four tiles, the timeline and the request previews,
/// because every caption on the client's HTML is a phrase built from counts
/// ("2 completed · 2 upcoming") and the counts are already in hand there.
/// This class shapes, it does not calculate.
///
/// One route rather than three: `today` + `requests` + `earnings` is three
/// round-trips on a cold mobile connection, and "active clients" is in none
/// of them.
class ApiDashboardRepository implements DashboardRepository {
  const ApiDashboardRepository(this._api);

  final ApiClient _api;

  @override
  Future<DashboardSummary> load() async {
    final result = await _api.get<DashboardSummary>(
      '/app/instructor/dashboard',
      parse: _summary,
    );

    return switch (result) {
      ApiSuccess(:final data) => data,
      // The screen's `error` branch shows this; it must not be swallowed into
      // a half-empty dashboard that looks like real zeroes.
      ApiFailure(:final message) => throw Exception(message),
    };
  }

  static DashboardSummary _summary(dynamic raw) {
    final json = raw as Map<String, dynamic>;
    final trainer = (json['trainer'] as Map<String, dynamic>?) ?? const {};
    final name = (trainer['name'] as String?)?.trim();

    return DashboardSummary(
      greeting: _greeting(),
      // The HTML prints the name in orange after "WELCOME BACK," — first name
      // only, upper-cased, so a long full name cannot wrap the heading.
      trainerName: _firstName(name),
      verification: _verification(trainer['stage'] as String?),
      metrics: _list(json['metrics'], _metric),
      schedule: _list(json['schedule'], _schedule),
      requests: _list(json['requests'], _request),
    );
  }

  static List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) of) =>
      switch (raw) {
        final List<dynamic> list =>
          list.map((e) => of(e as Map<String, dynamic>)).toList(),
        _ => const [],
      };

  static OverviewMetric _metric(Map<String, dynamic> json) => OverviewMetric(
    title: json['title'] as String? ?? '',
    value: json['value'] as String? ?? '—',
    caption: json['caption'] as String? ?? '',
  );

  static ScheduleEntry _schedule(Map<String, dynamic> json) => ScheduleEntry(
    time: json['time'] as String? ?? '',
    meridiem: json['meridiem'] as String? ?? '',
    service: json['service'] as String? ?? '',
    clientLine: json['clientLine'] as String? ?? '',
    status: json['status'] as String? ?? '',
  );

  static BookingRequestPreview _request(Map<String, dynamic> json) =>
      BookingRequestPreview(
        initials: json['initials'] as String? ?? '?',
        title: json['title'] as String? ?? 'New client request',
        subtitle: json['subtitle'] as String? ?? '',
      );

  /// `APPROVED` is the only stage that clears the banner. `REJECTED` shows
  /// the rejected variant; everything else is still in the pipeline.
  static VerificationState _verification(String? stage) => switch (stage) {
    'APPROVED' => VerificationState.approved,
    'REJECTED' => VerificationState.rejected,
    _ => VerificationState.pending,
  };

  /// Read off the device clock, not the server: the greeting is about where
  /// the trainer is standing, and the API sends no local time.
  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  static String _firstName(String? name) {
    if (name == null || name.isEmpty) return 'TRAINER!';
    return '${name.split(RegExp(r'\s+')).first.toUpperCase()}!';
  }
}
