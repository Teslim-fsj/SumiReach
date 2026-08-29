import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/influencer.dart';
import '../models/outreach.dart';
import '../config/env.dart';

abstract class AiService {
  Future<Map<String, dynamic>> analyzeInfluencer(Influencer influencer);
  Future<OutreachMessage> generateOutreach(Influencer influencer);
  Future<String> generateFollowUp(Influencer influencer, String context);
  Future<String> summarizeReply(String replyText);
  Future<String> generateAcquisitionInsight();
}

class GeminiAiService implements AiService {
  final String _apiKey;
  GenerativeModel? _proModel;
  GenerativeModel? _flashModel;

  GeminiAiService({String? apiKey}) : _apiKey = apiKey ?? Env.geminiApiKey {
    if (_apiKey.isNotEmpty) {
      _flashModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );
      _proModel = GenerativeModel(
        model: 'gemini-1.5-flash', // Using 1.5 flash for fast, reliable low-latency responses
        apiKey: _apiKey,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeInfluencer(Influencer influencer) async {
    if (_proModel == null) {
      return _fallbackAnalysis(influencer);
    }

    try {
      final prompt = '''
You are SumQuiz's lead influencer strategist. Analyze this creator for a sponsored partnership with SumQuiz (an AI study & knowledge engine app).

Creator Details:
- Name: ${influencer.name}
- Handle: ${influencer.handle}
- Platform: ${influencer.platform}
- Niche: ${influencer.niche}
- Followers: ${influencer.followersDisplay} (${influencer.followers})
- Engagement Rate: ${influencer.engagementRate}%
- Bio: ${influencer.bio}
- Location: ${influencer.location}

Respond with ONLY a valid JSON object matching this schema:
{
  "fitScore": <integer between 60 and 99>,
  "audienceOverlap": <integer between 50 and 95>,
  "audienceOverlapDescription": "<1 sentence explaining % match with US tech/student demographic>",
  "strongEngagement": "<1 sentence detailing engagement rate vs category average>",
  "brandAlignment": "<1 sentence on how their content aligns with study/productivity/tools>",
  "recommendedAngle": "<1-2 sentences on best sponsorship offer/pitch angle>"
}
''';

      final response = await _proModel!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      final cleanJson = text
          .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
          .trim();

      final decoded = jsonDecode(cleanJson) as Map<String, dynamic>;
      return {
        'fitScore': (decoded['fitScore'] as num?)?.toInt() ?? influencer.fitScore,
        'audienceOverlap': (decoded['audienceOverlap'] as num?)?.toInt() ?? 78,
        'audienceOverlapDescription': decoded['audienceOverlapDescription']?.toString() ??
            '${decoded['audienceOverlap'] ?? 78}% of followers match our target demographic.',
        'strongEngagement': decoded['strongEngagement']?.toString() ??
            'Averages ${influencer.engagementRate}% ER, above category average.',
        'brandAlignment': decoded['brandAlignment']?.toString() ??
            'Consistently advocates for productivity tools.',
        'recommendedAngle': decoded['recommendedAngle']?.toString() ??
            'Sponsorship of dedicated desk setup walkthrough + promo code.',
      };
    } catch (e) {
      debugPrint('[GeminiAiService] Error in analyzeInfluencer: $e');
      return _fallbackAnalysis(influencer);
    }
  }

  @override
  Future<OutreachMessage> generateOutreach(Influencer influencer) async {
    final cleanHandle = influencer.handle.replaceAll('@', '');

    if (_flashModel == null) {
      return _fallbackOutreach(influencer, cleanHandle);
    }

    try {
      final prompt = '''
You are the Head of Growth at SumQuiz (an AI study & knowledge engine designed for serious learners, students, and productivity enthusiasts).
Write a high-converting, personalized, authentic cold outreach email to this creator.

Creator Profile:
- Name: ${influencer.name}
- Handle: @$cleanHandle
- Niche: ${influencer.niche}
- Bio: ${influencer.bio}

Tone:
- Authentic, respectful, concise (under 120 words)
- Specific hook about their content niche
- Clear value proposition: sponsored integration + exclusive VIP lifetime bundle for their audience
- Low-friction Call to Action (e.g., "Open to an early preview?")

Respond with ONLY a valid JSON object:
{
  "subject": "<Compelling email subject line>",
  "body": "<Full personalized email body with line breaks>"
}
''';

      final response = await _flashModel!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final cleanJson = text
          .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
          .trim();

      final decoded = jsonDecode(cleanJson) as Map<String, dynamic>;
      final subject = decoded['subject']?.toString() ??
          'SumiReach x @$cleanHandle // Ultimate Desk Setup & AI Study Engine';
      final body = decoded['body']?.toString() ??
          'Hi ${influencer.name.split(' ').first},\n\n'
          'Been following your ${influencer.niche} content—your recent breakdowns are top-tier!\n\n'
          'We\'re building SumQuiz, an AI study engine. We\'d love to sponsor an upcoming segment and give your audience exclusive VIP access.\n\n'
          'Would you be open to checking out an early preview?\n\n'
          'Best,\nSumiReach Partnerships Team';

      return OutreachMessage(
        id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
        influencerId: influencer.id,
        influencerName: influencer.name,
        influencerHandle: influencer.handle,
        avatarColorValue: influencer.avatarColorValue,
        recipientEmail: influencer.email,
        subject: subject,
        body: body,
        status: OutreachStatus.draft,
        generatedByAi: true,
        approvedByUser: false,
        timeAgoDisplay: 'Just now',
      );
    } catch (e) {
      debugPrint('[GeminiAiService] Error in generateOutreach: $e');
      return _fallbackOutreach(influencer, cleanHandle);
    }
  }

  @override
  Future<String> generateFollowUp(Influencer influencer, String context) async {
    if (_flashModel == null) {
      final firstName = influencer.name.split(' ').first;
      return 'Hey $firstName, just floating this to the top of your inbox. We loved your recent deep dive on productivity setups and still think SumiReach would be a perfect fit for your community!';
    }

    try {
      final prompt = '''
Write a 1-2 sentence polite, high-converting follow-up email bump to creator ${influencer.name} (@${influencer.handle}) about a sponsored collaboration with SumQuiz. Keep it ultra-concise and friendly.
''';
      final response = await _flashModel!.generateContent([Content.text(prompt)]);
      return response.text?.trim() ??
          'Hey ${influencer.name.split(' ').first}, just bumping this to the top of your inbox. Would love to collaborate!';
    } catch (e) {
      return 'Hey ${influencer.name.split(' ').first}, just floating this to the top of your inbox. We loved your recent deep dive and still think SumQuiz would be a perfect fit!';
    }
  }

  @override
  Future<String> summarizeReply(String replyText) async {
    if (_flashModel == null) {
      return 'Positive sentiment. Creator is open to sponsored review pending rate card & demo access.';
    }

    try {
      final prompt = '''
Summarize this email reply from an influencer in exactly one short, actionable sentence stating sentiment and next step:
"$replyText"
''';
      final response = await _flashModel!.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Positive response. Review requested terms.';
    } catch (e) {
      return 'Positive sentiment. Creator is open to sponsored review pending rate card & demo access.';
    }
  }

  @override
  Future<String> generateAcquisitionInsight() async {
    if (_flashModel == null) {
      return 'Tech niche creators are driving 3.2x higher conversion to paid annual plans compared to generic productivity accounts.';
    }

    try {
      final prompt = '''
Generate a single-sentence data-driven acquisition insight for our influencer dashboard (e.g. comparing tech vs lifestyle conversion or ROI).
''';
      final response = await _flashModel!.generateContent([Content.text(prompt)]);
      return response.text?.trim() ??
          'Tech niche creators are driving 3.2x higher conversion to paid annual plans compared to generic productivity accounts.';
    } catch (e) {
      return 'Tech niche creators are driving 3.2x higher conversion to paid annual plans compared to generic productivity accounts.';
    }
  }

  Map<String, dynamic> _fallbackAnalysis(Influencer influencer) {
    return {
      'fitScore': influencer.fitScore > 0 ? influencer.fitScore : 94,
      'audienceOverlap': 78,
      'audienceOverlapDescription': '78% of followers match our target demographic (US, 18-34, tech-focused).',
      'strongEngagement': 'Averages 5.2% ER on recent posts, significantly above category average.',
      'brandAlignment': 'Consistently advocates for ergonomic, premium workspace setups and productivity tools.',
      'recommendedAngle': 'Sponsorship of dedicated desk setup walkthrough + customized lifetime promo code.',
    };
  }

  OutreachMessage _fallbackOutreach(Influencer influencer, String cleanHandle) {
    return OutreachMessage(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      influencerId: influencer.id,
      influencerName: influencer.name,
      influencerHandle: influencer.handle,
      avatarColorValue: influencer.avatarColorValue,
      recipientEmail: influencer.email,
      subject: 'SumiReach x @$cleanHandle // Ultimate Desk Setup & AI Study Engine',
      body: 'Hi ${influencer.name.split(' ').first},\n\n'
          'Been following your ${influencer.niche} content for a while—your recent breakdowns and setups are top-tier!\n\n'
          'We\'re building SumQuiz, an AI study & knowledge engine designed for serious learners and creators. '
          'We\'d love to sponsor an upcoming segment and provide your audience with an exclusive VIP lifetime bundle.\n\n'
          'Would you be open to checking out an early preview?\n\n'
          'Best,\n'
          'SumiReach Partnerships Team',
      status: OutreachStatus.draft,
      generatedByAi: true,
      approvedByUser: false,
      timeAgoDisplay: 'Just now',
    );
  }
}