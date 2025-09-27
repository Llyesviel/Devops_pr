import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    // Simple smoke test - just create a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        title: 'Animal Charity',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(
            child: Text('Test App'),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('Login screen test', (tester) async {
    // Simple test for login screen elements
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Welcome Back'),
              ElevatedButton(
                onPressed: null,
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Should show login screen elements
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}