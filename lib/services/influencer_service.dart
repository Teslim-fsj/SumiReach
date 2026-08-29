import '../models/influencer.dart';
import 'firestore_service.dart';

class InfluencerService {
  final FirestoreService _firestoreService;

  InfluencerService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<List<Influencer>> getInfluencers({
    String? query,
    InfluencerCategory? category,
  }) async {
    return _firestoreService.getInfluencers(
      query: query,
      category: category,
    );
  }

  Stream<List<Influencer>> getInfluencersStream() {
    return _firestoreService.getInfluencersStream();
  }

  Future<Influencer?> getInfluencerById(String id) async {
    return _firestoreService.getInfluencerById(id);
  }

  Future<Influencer> addInfluencer(Influencer influencer) async {
    return _firestoreService.addInfluencer(influencer);
  }

  Future<Influencer> updateInfluencer(Influencer updated) async {
    return _firestoreService.updateInfluencer(updated);
  }
}