import 'package:flutter/material.dart';
import '../models/followup.dart';
import '../services/gmail_service.dart';
import '../services/firestore_service.dart';

class FollowUpProvider extends ChangeNotifier {
  final GmailService _gmailService;
  final FirestoreService _firestoreService;
  List<FollowUpItem> _items = [];
  bool _isLoading = false;

  FollowUpProvider({
    required GmailService gmailService,
    required FirestoreService firestoreService,
  })  : _gmailService = gmailService,
        _firestoreService = firestoreService {
    Future.microtask(() => fetchFollowUps());
  }

  List<FollowUpItem> get items =>
      _items.where((i) => i.status == FollowUpStatus.pending).toList();
  bool get isLoading => _isLoading;
  int get pendingCount => items.length;

  Future<void> fetchFollowUps() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _firestoreService.getFollowUps();
    } catch (e) {
      debugPrint('[FollowUpProvider] fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendFollowUp(FollowUpItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _gmailService.sendOutreachEmail(
        to: item.email,
        subject: item.subject,
        body: item.suggestedBody,
      );

      final updated = item.copyWith(status: FollowUpStatus.sent);
      await _firestoreService.updateFollowUp(updated);

      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = updated;
      }
    } catch (e) {
      debugPrint('Error sending follow-up: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> skipFollowUp(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final updated = _items[index].copyWith(status: FollowUpStatus.skipped);
      _items[index] = updated;
      notifyListeners();
      await _firestoreService.updateFollowUp(updated);
    }
  }

  Future<void> updateFollowUpBody(String id, String newBody) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final updated = _items[index].copyWith(suggestedBody: newBody);
      _items[index] = updated;
      notifyListeners();
      await _firestoreService.updateFollowUp(updated);
    }
  }
}