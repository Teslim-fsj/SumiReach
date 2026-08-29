import '../models/analytics_data.dart';
import 'firestore_service.dart';

class AnalyticsService {
  final FirestoreService _firestoreService;

  AnalyticsService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<DashboardStats> getDashboardStats() async {
    return _firestoreService.getDashboardStats();
  }

  Future<List<PrioritizedActionItem>> getPrioritizedActions() async {
    return _firestoreService.getPrioritizedActions();
  }

  Future<AnalyticsOverview> getAnalyticsOverview() async {
    return _firestoreService.getAnalyticsOverview();
  }
}