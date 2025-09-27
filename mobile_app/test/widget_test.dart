import 'package:animal_charity_app/main.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnimalCharityApp());

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Login screen test', (tester) async {
    await tester.pumpWidget(const AnimalCharityApp());

    // Wait for the splash screen to finish
    await tester.pumpAndSettle();

    // Should show login screen initially (when not authenticated)
    expect(find.text('Login'), findsWidgets);
  });
}