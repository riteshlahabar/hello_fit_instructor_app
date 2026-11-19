import 'package:flutter/foundation.dart';

/// Where the provider is paid, as `GET /app/instructor/bank-account` returns
/// it. The full account number never leaves the server — only the masked tail
/// comes back.
///
/// **UPI or bank, never both** (client, 19-11-2026 — page 20 is a radio), so
/// every field but [payoutMethod] is nullable: the side not chosen is null.
@immutable
class BankAccount {
  const BankAccount({
    required this.payoutMethod,
    required this.verified,
    this.holderName,
    this.bankName,
    this.accountNumberMasked,
    this.ifsc,
    this.accountType,
    this.upiId,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
    payoutMethod: json['payoutMethod'] as String? ?? 'BANK',
    verified: json['verified'] as bool? ?? false,
    holderName: json['holderName'] as String?,
    bankName: json['bankName'] as String?,
    accountNumberMasked: json['accountNumberMasked'] as String?,
    ifsc: json['ifsc'] as String?,
    accountType: json['accountType'] as String?,
    upiId: json['upiId'] as String?,
  );

  /// `UPI` or `BANK`.
  final String payoutMethod;
  final bool verified;
  final String? holderName;
  final String? bankName;
  final String? accountNumberMasked;
  final String? ifsc;
  final String? accountType;
  final String? upiId;

  bool get isUpi => payoutMethod == 'UPI';
}
