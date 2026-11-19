import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/core/theme/app_theme.dart';
import 'package:trainer_app/features/shell/presentation/trainer_shell.dart';

void main() {
  testWidgets('shell shows the dashboard and all five tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const TrainerShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['Home', 'Clients', 'Earnings', 'Profile']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('Your overview'), findsOneWidget);
    expect(find.text('Profile verification in progress'), findsOneWidget);
  });
}
