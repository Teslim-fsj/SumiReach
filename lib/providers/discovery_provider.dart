import 'package:flutter/material.dart';
import '../models/discovered_candidate.dart';
import '../services/web_search_service.dart';
import 'influencer_provider.dart';

enum DiscoveryState {
  initial,
  searching,
  results,
  empty,
  error,
}

class DiscoveryProvider extends ChangeNotifier {
  final WebSearchService _webSearchService;

  String _searchQuery = '';
  DiscoveryFilters _filters = const DiscoveryFilters();
  DiscoveryState _state = DiscoveryState.initial;
  DiscoverySearchStep _currentStep = DiscoverySearchStep.interpreting;
  List<DiscoveredCandidate> _candidates = [];
  final Set<String> _selectedCandidateIds = {};
  final List<String> _searchHistory = [
    'Nigerian TikTok creators who make JAMB and WAEC content',
    'Lagos student creators with 10K-100K followers',
    'Nigerian education YouTubers for exam prep',
    'African study influencers and productivity creators',
  ];
  String? _errorMessage;

  DiscoveryProvider({required WebSearchService webSearchService})
      : _webSearchService = webSearchService;

  String get searchQuery => _searchQuery;
  DiscoveryFilters get filters => _filters;
  DiscoveryState get state => _state;
  DiscoverySearchStep get currentStep => _currentStep;
  List<DiscoveredCandidate> get candidates => _candidates;
  Set<String> get selectedCandidateIds => _selectedCandidateIds;
  List<String> get searchHistory => _searchHistory;
  String? get errorMessage => _errorMessage;
  bool get isSearching => _state == DiscoveryState.searching;
  int get selectedCount => _selectedCandidateIds.length;
  int get strongMatchCount => _candidates.where((c) => c.fitScore >= 90).length;

  void setQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateFilters(DiscoveryFilters filters) {
    _filters = filters;
    notifyListeners();
  }

  void resetFilters() {
    _filters = const DiscoveryFilters();
    notifyListeners();
  }

  Future<void> search(String query, {InfluencerProvider? influencerProvider}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    _searchQuery = cleanQuery;
    _state = DiscoveryState.searching;
    _currentStep = DiscoverySearchStep.interpreting;
    _errorMessage = null;
    _selectedCandidateIds.clear();
    notifyListeners();

    // Update history
    if (!_searchHistory.contains(cleanQuery)) {
      _searchHistory.insert(0, cleanQuery);
      if (_searchHistory.length > 8) {
        _searchHistory.removeLast();
      }
    }

    try {
      final results = await _webSearchService.searchAndDiscover(
        naturalLanguageQuery: cleanQuery,
        filters: _filters,
        onProgress: (step) {
          _currentStep = step;
          notifyListeners();
        },
      );

      // Deduplicate against existing roster in InfluencerProvider
      final existingInfluencers = influencerProvider?.influencers ?? [];
      final existingHandles = existingInfluencers.map((inf) => inf.handle.toLowerCase().replaceAll('@', '')).toSet();
      final existingEmails = existingInfluencers.where((inf) => inf.email.isNotEmpty).map((inf) => inf.email.toLowerCase()).toSet();

      _candidates = results.map((candidate) {
        final cleanHandle = candidate.handle.toLowerCase().replaceAll('@', '');
        final cleanEmail = candidate.email?.toLowerCase() ?? '';

        final isAlreadyInRoster = existingHandles.contains(cleanHandle) ||
            (cleanEmail.isNotEmpty && existingEmails.contains(cleanEmail));

        if (isAlreadyInRoster) {
          final existing = existingInfluencers.firstWhere(
            (inf) => inf.handle.toLowerCase().replaceAll('@', '') == cleanHandle || (cleanEmail.isNotEmpty && inf.email.toLowerCase() == cleanEmail),
          );
          return candidate.copyWith(
            isSaved: true,
            existingInfluencerId: existing.id,
          );
        }
        return candidate;
      }).toList();

      // Pre-select all unsaved candidates with high fit
      for (final c in _candidates) {
        if (!c.isSaved) {
          _selectedCandidateIds.add(c.id);
        }
      }

      if (_candidates.isEmpty) {
        _state = DiscoveryState.empty;
      } else {
        _state = DiscoveryState.results;
      }
    } catch (e) {
      debugPrint('[DiscoveryProvider] Search error: $e');
      _errorMessage = 'We couldn\'t complete the web search. Please check your connection and try again.';
      _state = DiscoveryState.error;
    } finally {
      notifyListeners();
    }
  }

  void toggleCandidateSelection(String candidateId) {
    if (_selectedCandidateIds.contains(candidateId)) {
      _selectedCandidateIds.remove(candidateId);
    } else {
      _selectedCandidateIds.add(candidateId);
    }
    notifyListeners();
  }

  void selectAll() {
    for (final c in _candidates) {
      if (!c.isSaved) {
        _selectedCandidateIds.add(c.id);
      }
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedCandidateIds.clear();
    notifyListeners();
  }

  Future<bool> saveSingleCandidate(DiscoveredCandidate candidate, InfluencerProvider influencerProvider) async {
    try {
      final newInfluencer = candidate.toInfluencer();
      await influencerProvider.addInfluencer(newInfluencer);

      final index = _candidates.indexWhere((c) => c.id == candidate.id);
      if (index != -1) {
        _candidates[index] = _candidates[index].copyWith(
          isSaved: true,
          existingInfluencerId: newInfluencer.id,
        );
        _selectedCandidateIds.remove(candidate.id);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[DiscoveryProvider] Error saving candidate: $e');
      return false;
    }
  }

  Future<int> saveSelectedCandidates(InfluencerProvider influencerProvider) async {
    int savedCount = 0;
    final toSave = _candidates.where((c) => _selectedCandidateIds.contains(c.id) && !c.isSaved).toList();

    for (final candidate in toSave) {
      try {
        final newInfluencer = candidate.toInfluencer();
        await influencerProvider.addInfluencer(newInfluencer);

        final index = _candidates.indexWhere((c) => c.id == candidate.id);
        if (index != -1) {
          _candidates[index] = _candidates[index].copyWith(
            isSaved: true,
            existingInfluencerId: newInfluencer.id,
          );
        }
        savedCount++;
      } catch (e) {
        debugPrint('[DiscoveryProvider] Error bulk saving candidate ${candidate.name}: $e');
      }
    }

    _selectedCandidateIds.clear();
    notifyListeners();
    return savedCount;
  }
}