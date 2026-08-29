import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/influencer_service.dart';
import 'services/outreach_service.dart';
import 'services/analytics_service.dart';
import 'services/ai_service.dart';
import 'services/gmail_service.dart';
import 'services/sheets_service.dart';
import 'services/web_search_service.dart';
import 'providers/auth_provider.dart';
import 'providers/influencer_provider.dart';
import 'providers/outreach_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/followup_provider.dart';
import 'providers/integrations_provider.dart';
import 'providers/discovery_provider.dart';
import 'screens/shell/app_shell.dart';
import 'screens/auth/login_screen.dart';
import 'screens/discovery/discovery_screen.dart';
import 'screens/splash/splash_screen.dart';

class SumiReachApp extends StatelessWidget {
  final AuthService? authService;
  final FirestoreService? firestoreService;
  final InfluencerService? influencerService;
  final OutreachService? outreachService;
  final AnalyticsService? analyticsService;
  final AiService? aiService;
  final GmailService? gmailService;
  final SheetsService? sheetsService;
  final WebSearchService? webSearchService;
  final bool skipSplash;

  const SumiReachApp({
    super.key,
    this.authService,
    this.firestoreService,
    this.influencerService,
    this.outreachService,
    this.analyticsService,
    this.aiService,
    this.gmailService,
    this.sheetsService,
    this.webSearchService,
    this.skipSplash = false,
  });

  @override
  Widget build(BuildContext context) {
    // Live Service Layer with fallback dependency injection
    final liveAuthService = authService ?? AuthService();
    final liveFirestoreService = firestoreService ?? FirestoreService();
    final liveInfluencerService = influencerService ?? InfluencerService(firestoreService: liveFirestoreService);
    final liveOutreachService = outreachService ?? OutreachService(firestoreService: liveFirestoreService);
    final liveAnalyticsService = analyticsService ?? AnalyticsService(firestoreService: liveFirestoreService);
    final liveAiService = aiService ?? GeminiAiService();
    final liveGmailService = gmailService ?? RealGmailService(authService: liveAuthService);
    final liveSheetsService = sheetsService ?? RealSheetsService(authService: liveAuthService);
    final liveWebSearchService = webSearchService ?? GeminiWebSearchService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: liveAuthService),
        ),
        ChangeNotifierProvider(
          create: (_) => InfluencerProvider(
            influencerService: liveInfluencerService,
            aiService: liveAiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OutreachProvider(
            outreachService: liveOutreachService,
            gmailService: liveGmailService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FollowUpProvider(
            gmailService: liveGmailService,
            firestoreService: liveFirestoreService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(
            analyticsService: liveAnalyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => IntegrationsProvider(
            gmailService: liveGmailService,
            sheetsService: liveSheetsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DiscoveryProvider(
            webSearchService: liveWebSearchService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SumiReach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const AppShell(),
          '/discover': (_) => const DiscoveryScreen(),
        },
        home: _AuthGate(skipSplash: skipSplash),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  final bool skipSplash;
  const _AuthGate({this.skipSplash = false});

  @override
  Widget build(BuildContext context) {
    if (skipSplash) {
      return const AppShell();
    }
    return const SplashScreen();
  }
}