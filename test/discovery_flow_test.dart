import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumireach/app.dart';
import 'package:sumireach/models/discovered_candidate.dart';
import 'package:sumireach/models/influencer.dart';
import 'package:sumireach/services/web_search_service.dart';

class MockWebSearchService implements WebSearchService {
  @override
  Future<List<DiscoveredCandidate>> searchAndDiscover({
    required String naturalLanguageQuery,
    DiscoveryFilters? filters,
    void Function(DiscoverySearchStep)? onProgress,
  }) async {
    onProgress?.call(DiscoverySearchStep.interpreting);
    onProgress?.call(DiscoverySearchStep.searching);
    onProgress?.call(DiscoverySearchStep.identifying);
    onProgress?.call(DiscoverySearchStep.qualifying);
    onProgress?.call(DiscoverySearchStep.deduplicating);
    onProgress?.call(DiscoverySearchStep.ranking);
    onProgress?.call(DiscoverySearchStep.completed);

    return [
      const DiscoveredCandidate(
        id: 'cand_test_1',
        name: 'Tunde Bakare',
        handle: '@jambprep_tunde',
        platform: 'TikTok',
        profileUrl: 'https://tiktok.com/@jambprep_tunde',
        followers: 48500,
        followersDisplay: '48.5K',
        engagementRate: 6.4,
        niche: 'JAMB CBT & WAEC Science',
        category: InfluencerCategory.lifestyle,
        location: 'Lagos, Nigeria',
        email: 'tunde@gmail.com',
        hasPublicEmail: true,
        bio: 'Full-time educator breaking down JAMB Physics past questions daily.',
        relevantContent: 'CBT speed hacks and WAEC solutions.',
        fitScore: 96,
        fitReason: 'Exceptional alignment with SumQuiz CBT practice engine.',
        sources: [
          CandidateSource(title: 'TikTok Creator Profile', url: 'https://www.tiktok.com/@jambprep_tunde', sourceType: 'TikTok'),
        ],
      ),
      const DiscoveredCandidate(
        id: 'cand_test_2',
        name: 'Kemi Adeyemi',
        handle: '@kemi_studycorner',
        platform: 'TikTok',
        profileUrl: 'https://tiktok.com/@kemi_studycorner',
        followers: 32000,
        followersDisplay: '32K',
        engagementRate: 5.9,
        niche: 'Study With Me & University Prep',
        category: InfluencerCategory.lifestyle,
        location: 'Ibadan, Nigeria',
        email: null,
        hasPublicEmail: false,
        bio: 'Pre-med student sharing study routines and flashcards.',
        relevantContent: 'Spaced repetition flashcards and UTME study tips.',
        fitScore: 93,
        fitReason: 'High organic engagement with students seeking digital study tools.',
        sources: [
          CandidateSource(title: 'TikTok Account', url: 'https://www.tiktok.com/@kemi_studycorner', sourceType: 'TikTok'),
        ],
      ),
    ];
  }
}

void main() {
  testWidgets('Web Discovery workflow: Search, Inspect Sources, AI Fit Score & Save to Roster', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockSearchService = MockWebSearchService();

    await tester.pumpWidget(
      SumiReachApp(
        webSearchService: mockSearchService,
        skipSplash: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 1. Navigate to Influencers Tab
    await tester.tap(find.text('Influencers'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 2. Open Discovery Screen via discovery button
    final discoverButton = find.byIcon(Icons.travel_explore_rounded);
    expect(discoverButton, findsOneWidget);
    await tester.tap(discoverButton);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 3. Verify Discovery Screen Elements
    expect(find.text('Discover Influencers'), findsOneWidget);
    expect(find.text('Find potential SumQuiz partners across the web.'), findsOneWidget);
    expect(find.text('Search Web'), findsOneWidget);

    // 4. Enter search query & trigger search
    await tester.enterText(
      find.byType(TextField).first,
      'Nigerian TikTok creators who make JAMB and WAEC content',
    );
    await tester.tap(find.text('Search Web'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 5. Verify Discovered Candidates Results
    expect(find.text('Tunde Bakare'), findsOneWidget);
    expect(find.text('@jambprep_tunde'), findsOneWidget);
    expect(find.text('Kemi Adeyemi'), findsOneWidget);
    expect(find.text('Email found'), findsOneWidget);
    expect(find.text('No public email'), findsOneWidget);

    // 6. View Candidate Evidence Modal
    await tester.tap(find.text('View Evidence').first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Discovered Creator Details'), findsOneWidget);
    expect(find.text('Public Web Sources & Evidence'), findsOneWidget);
    expect(find.text('TikTok Creator Profile'), findsOneWidget);

    // 7. Save candidate from modal to SumiReach
    await tester.tap(find.text('Save Candidate to SumiReach'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 8. Go back to Influencers Roster and verify newly saved creator is present
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify Tunde Bakare is now in the main Influencer roster
    expect(find.text('Tunde Bakare'), findsOneWidget);
  });
}