import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumireach/app.dart';

void main() {
  testWidgets('Complete user workflow: Browse, Filter, Profile, AI Pitch, Pipeline & Insights', (WidgetTester tester) async {
    await tester.pumpWidget(const SumiReachApp(skipSplash: true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // 1. Dashboard is active
    expect(find.text('Good morning.'), findsOneWidget);
    expect(find.text('Active Deals'), findsOneWidget);
    expect(find.text('Prioritized Actions'), findsOneWidget);

    // 2. Navigate to Influencers Tab
    await tester.tap(find.text('Influencers'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify creators list
    expect(find.text('Alex Chen'), findsOneWidget);
    expect(find.text('Sarah Jenkins'), findsOneWidget);
    expect(find.text('High Fit'), findsOneWidget);

    // Filter by Lifestyle
    await tester.tap(find.text('Lifestyle'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Sarah Jenkins'), findsOneWidget);

    // Switch back to High Fit
    await tester.tap(find.text('High Fit'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 3. Open Alex Chen Profile
    await tester.tap(find.text('Alex Chen'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify Profile Elements
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('AI Fit Analysis'), findsOneWidget);
    expect(find.text('Draft Outreach'), findsOneWidget);
    expect(find.text('Generate & Send Pitch'), findsOneWidget);

    // Go back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 4. Navigate to Outreach / Pipeline Tab
    await tester.tap(find.text('Outreach'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Pipeline'), findsOneWidget);
    expect(find.text('Drafts'), findsOneWidget);
    expect(find.text('Sent'), findsOneWidget);
    expect(find.text('Replied'), findsOneWidget);
    expect(find.text('Passed'), findsOneWidget);

    // Switch to Drafts tab
    await tester.tap(find.text('Drafts'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 5. Navigate to Insights Tab
    await tester.tap(find.text('Insights'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Acquisition Velocity'), findsOneWidget);
    expect(find.text('Top Partners'), findsOneWidget);
    expect(find.text('Clara Santana'), findsOneWidget);
  });
}
