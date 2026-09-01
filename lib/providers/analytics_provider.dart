import 'package:flutter/material.dart';
import '../models/analytics_data.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService;

  DashboardStats? _dashboardStats;
  List<PrioritizedActionItem> _prioritizedActions = [];
  AnalyticsOverview? _analyticsOverview;
  bool _isLoading = false;
  String _selectedPeriod = 'This Month';

  AnalyticsProvider({required AnalyticsService analyticsService})
      : _analyticsService = analyticsService {
    Future.microtask(() => fetchDashboardData());
  }

  DashboardStats? get dashboardStats => _dashboardStats;
  List<PrioritizedActionItem> get prioritizedActions => _prioritizedActions;
  AnalyticsOverview? get analyticsOverview => _analyticsOverview;
  bool get isLoading => _isLoading;
  String get selectedPeriod => _selectedPeriod;

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dashboardStats = await _analyticsService.getDashboardStats();
      _prioritizedActions = await _analyticsService.getPrioritizedActions();
      _analyticsOverview = await _analyticsService.getAnalyticsOverview();
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeAction(String actionId) {
    _prioritizedActions.removeWhere((a) => a.id == actionId);
    notifyListeners();
  }
}
