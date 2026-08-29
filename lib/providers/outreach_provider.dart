import 'package:flutter/material.dart';
import '../models/outreach.dart';
import '../services/outreach_service.dart';
import '../services/gmail_service.dart';

class OutreachProvider extends ChangeNotifier {
  final OutreachService _outreachService;
  final GmailService _gmailService;

  OutreachStatus _selectedTab = OutreachStatus.sent;
  List<OutreachMessage> _messages = [];
  bool _isLoading = false;
  String _searchQuery = '';

  OutreachProvider({
    required OutreachService outreachService,
    required GmailService gmailService,
  })  : _outreachService = outreachService,
        _gmailService = gmailService {
    fetchMessages();
  }

  OutreachStatus get selectedTab => _selectedTab;
  List<OutreachMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void setSelectedTab(OutreachStatus status) {
    _selectedTab = status;
    fetchMessages();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allByStatus = await _outreachService.getMessagesByStatus(_selectedTab);
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        _messages = allByStatus.where((m) =>
          m.influencerName.toLowerCase().contains(q) ||
          m.influencerHandle.toLowerCase().contains(q) ||
          m.subject.toLowerCase().contains(q) ||
          m.body.toLowerCase().contains(q)
        ).toList();
      } else {
        _messages = allByStatus;
      }
    } catch (e) {
      debugPrint('Error fetching outreach messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendDraft(OutreachMessage draft) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Send via Gmail service
      await _gmailService.sendOutreachEmail(
        to: draft.recipientEmail,
        subject: draft.subject,
        body: draft.body,
      );

      // Transition draft to sent status
      await _outreachService.sendOutreach(draft);
      await fetchMessages();
      return true;
    } catch (e) {
      debugPrint('Error sending outreach: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> passOutreach(String messageId) async {
    try {
      await _outreachService.passOutreach(messageId);
      await fetchMessages();
    } catch (e) {
      debugPrint('Error passing outreach: $e');
    }
  }
}
