import 'package:flutter_test/flutter_test.dart';
import 'package:sumireach/app.dart';
import 'package:sumireach/widgets/app_logo.dart';
import 'package:sumireach/screens/splash/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders SumiReach logo, title, and navigates to AppShell', (WidgetTester tester) async {
    await tester.pumpWidget(
      const SumiReachApp(
        skipSplash: false,
      ),
    );

    // Verify Splash Screen elements
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('SumiReach'), findsOneWidget);
    expect(find.text('SumQuiz Influencer & Partnership Engine'), findsOneWidget);

    // Advance animation and duration timer
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Verify transition to main AppShell
    expect(find.text('Good morning.'), findsOneWidget);
    expect(find.text('Active Deals'), findsOneWidget);
  });
}