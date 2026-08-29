import 'package:flutter_test/flutter_test.dart';
import 'package:sumireach/app.dart';

void main() {
  testWidgets('SumiReach smoke test launches app and shows Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const SumiReachApp(skipSplash: true));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('SumiReach'), findsOneWidget);

    // Verify dashboard greetings & stats
    expect(find.text('Good morning.'), findsOneWidget);
    expect(find.text('Active Deals'), findsOneWidget);
    expect(find.text('Pending Replies'), findsOneWidget);
    expect(find.text('Prioritized Actions'), findsOneWidget);
  });
}
