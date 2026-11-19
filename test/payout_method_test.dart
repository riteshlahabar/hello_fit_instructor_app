import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/features/profile/domain/bank_account.dart';

/// Page 20 became a radio on 19-11-2026 (client): UPI **or** a bank account,
/// never both. The side not chosen comes back null, so the model has to cope
/// with every field but the method being absent.
void main() {
  group('BankAccount reads a one-sided payout', () {
    test('a bank account carries no UPI id', () {
      final account = BankAccount.fromJson(const {
        'payoutMethod': 'BANK',
        'holderName': 'Asha Rao',
        'bankName': 'HDFC Bank',
        'accountNumberMasked': '••••6789',
        'ifsc': 'HDFC0001234',
        'accountType': 'SAVINGS',
        'upiId': null,
        'verified': false,
      });

      expect(account.isUpi, isFalse);
      expect(account.accountNumberMasked, '••••6789');
      expect(account.upiId, isNull);
    });

    test('a UPI payout carries no bank fields at all', () {
      final account = BankAccount.fromJson(const {
        'payoutMethod': 'UPI',
        'holderName': null,
        'bankName': null,
        'accountNumberMasked': null,
        'ifsc': null,
        'accountType': null,
        'upiId': 'asha.rao@hdfc',
        'verified': false,
      });

      expect(account.isUpi, isTrue);
      expect(account.upiId, 'asha.rao@hdfc');
      // The screen must not try to show "account on file" for a UPI payout.
      expect(account.accountNumberMasked, isNull);
      expect(account.holderName, isNull);
      expect(account.ifsc, isNull);
      expect(account.accountType, isNull);
    });

    test('a row written before the radio existed reads as BANK', () {
      // Pre-19-11-2026 rows have no payoutMethod; the column defaults to
      // BANK and so does the model, rather than throwing on a missing key.
      final account = BankAccount.fromJson(const {
        'holderName': 'Old Row',
        'bankName': 'SBI',
        'accountNumberMasked': '••••1111',
        'verified': true,
      });

      expect(account.payoutMethod, 'BANK');
      expect(account.isUpi, isFalse);
      expect(account.verified, isTrue);
    });
  });
}
