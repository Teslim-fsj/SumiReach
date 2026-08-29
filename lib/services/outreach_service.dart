import '../models/outreach.dart';
import 'firestore_service.dart';

class OutreachService {
  final FirestoreService _firestoreService;

  OutreachService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<List<OutreachMessage>> getMessagesByStatus(OutreachStatus status) async {
    return _firestoreService.getMessagesByStatus(status);
  }

  Stream<List<OutreachMessage>> getOutreachStream() {
    return _firestoreService.getOutreachStream();
  }

  Future<OutreachMessage?> getDraftForInfluencer(String influencerId) async {
    try {
      final drafts = await _firestoreService.getMessagesByStatus(OutreachStatus.draft);
      return drafts.firstWhere((m) => m.influencerId == influencerId);
    } catch (_) {
      return null;
    }
  }

  Future<OutreachMessage> saveDraft(OutreachMessage message) async {
    return _firestoreService.saveDraft(message);
  }

  Future<OutreachMessage> sendOutreach(OutreachMessage draft) async {
    return _firestoreService.sendOutreach(draft);
  }

  Future<OutreachMessage> passOutreach(String messageId) async {
    return _firestoreService.passOutreach(messageId);
  }
}