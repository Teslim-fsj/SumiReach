import 'package:flutter/material.dart';
import '../models/influencer.dart';
import '../models/outreach.dart';
import '../services/influencer_service.dart';
import '../services/ai_service.dart';

class InfluencerProvider extends ChangeNotifier {
  final InfluencerService _influencerService;
  final AiService _aiService;

  List<Influencer> _influencers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  InfluencerCategory _selectedCategory = InfluencerCategory.highFit;

  Influencer? _selectedInfluencer;
  bool _isAnalyzingAi = false;
  Map<String, dynamic>? _aiAnalysisResult;

  OutreachMessage? _currentDraft;
  bool _isGeneratingPitch = false;

  InfluencerProvider({
    required InfluencerService influencerService,
    required AiService aiService,
  })  : _influencerService = influencerService,
        _aiService = aiService {
    Future.microtask(() => fetchInfluencers());
  }

  List<Influencer> get influencers => _influencers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  InfluencerCategory get selectedCategory => _selectedCategory;
  Influencer? get selectedInfluencer => _selectedInfluencer;
  bool get isAnalyzingAi => _isAnalyzingAi;
  Map<String, dynamic>? get aiAnalysisResult => _aiAnalysisResult;
  OutreachMessage? get currentDraft => _currentDraft;
  bool get isGeneratingPitch => _isGeneratingPitch;

  Future<void> fetchInfluencers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _influencers = await _influencerService.getInfluencers(
        query: _searchQuery,
        category: _selectedCategory,
      );
    } catch (e) {
      debugPrint('Error fetching influencers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchInfluencers();
  }

  void setCategory(InfluencerCategory category) {
    _selectedCategory = category;
    fetchInfluencers();
  }

  Future<void> selectInfluencer(String influencerId) async {
    _selectedInfluencer = await _influencerService.getInfluencerById(influencerId);
    if (_selectedInfluencer != null) {
      // Default / pre-cached analysis matching the design
      _aiAnalysisResult = {
        'fitScore': _selectedInfluencer!.fitScore,
        'audienceOverlap': _selectedInfluencer!.audienceOverlapPercent,
        'audienceOverlapDescription':
            '${_selectedInfluencer!.audienceOverlapPercent}% of followers match our target demographic (US, 18-34, tech-focused).',
        'strongEngagement': _selectedInfluencer!.strongEngagementText,
        'brandAlignment': _selectedInfluencer!.brandAlignmentText,
      };

      // Generate default draft preview
      _currentDraft = OutreachMessage(
        id: 'draft_${_selectedInfluencer!.id}',
        influencerId: _selectedInfluencer!.id,
        influencerName: _selectedInfluencer!.name,
        influencerHandle: _selectedInfluencer!.handle,
        avatarColorValue: _selectedInfluencer!.avatarColorValue,
        recipientEmail: _selectedInfluencer!.email,
        subject: 'SumiReach x ${_selectedInfluencer!.handle} // Ultimate Desk Setup & AI Study Engine',
        body: 'Hi ${_selectedInfluencer!.name.split(' ').first},\n\n'
            'Been following your mechanical keyboard builds for a while—that recent Alice layout showcase was incredible!\n\n'
            'We\'re building SumQuiz, an AI study & knowledge engine, and we love your focus on premium productivity setups. We\'d love to sponsor a dedicated setup spotlight video and offer your community lifetime VIP access.\n\n'
            'Let me know if you\'d be open to checking out a preview build!\n\n'
            'Best,\n'
            'SumiReach Team',
        status: OutreachStatus.draft,
        generatedByAi: true,
        approvedByUser: false,
      );
    }
    notifyListeners();
  }

  Future<void> triggerAiAnalysis() async {
    if (_selectedInfluencer == null) return;
    _isAnalyzingAi = true;
    notifyListeners();

    try {
      _aiAnalysisResult = await _aiService.analyzeInfluencer(_selectedInfluencer!);
    } catch (e) {
      debugPrint('Error running AI analysis: $e');
    } finally {
      _isAnalyzingAi = false;
      notifyListeners();
    }
  }

  Future<void> regeneratePitch() async {
    if (_selectedInfluencer == null) return;
    _isGeneratingPitch = true;
    notifyListeners();

    try {
      _currentDraft = await _aiService.generateOutreach(_selectedInfluencer!);
    } catch (e) {
      debugPrint('Error generating pitch: $e');
    } finally {
      _isGeneratingPitch = false;
      notifyListeners();
    }
  }

  void updateDraftBody(String newBody) {
    if (_currentDraft != null) {
      _currentDraft = _currentDraft!.copyWith(body: newBody);
      notifyListeners();
    }
  }

  void updateDraftSubject(String newSubject) {
    if (_currentDraft != null) {
      _currentDraft = _currentDraft!.copyWith(subject: newSubject);
      notifyListeners();
    }
  }

  Future<void> addInfluencer(Influencer influencer) async {
    await _influencerService.addInfluencer(influencer);
    await fetchInfluencers();
  }
}
