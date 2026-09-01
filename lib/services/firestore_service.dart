import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/influencer.dart';
import '../models/outreach.dart';
import '../models/followup.dart';
import '../models/partnership.dart';
import '../models/analytics_data.dart';
import '../data/seed_data.dart';

class FirestoreService {
  FirebaseFirestore? _firestore;

  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
      return _firestore;
    } catch (e) {
      debugPrint('[FirestoreService] Firebase not initialized in current runner: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _influencersCol =>
      _db?.collection('influencers');
  CollectionReference<Map<String, dynamic>>? get _outreachCol =>
      _db?.collection('outreach');
  CollectionReference<Map<String, dynamic>>? get _followupsCol =>
      _db?.collection('followups');
  CollectionReference<Map<String, dynamic>>? get _partnershipsCol =>
      _db?.collection('partnerships');

  /// Automatically seeds initial data into Firestore if collections are empty.
  Future<void> seedIfEmpty() async {
    final col = _influencersCol;
    if (col == null) return;

    try {
      final snapshot = await col.limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint('[FirestoreService] Seeding initial data into Firestore...');
        final batch = _db!.batch();

        for (final inf in SeedData.influencers) {
          final doc = _influencersCol!.doc(inf.id);
          batch.set(doc, inf.toMap());
        }

        for (final msg in SeedData.outreachMessages) {
          final doc = _outreachCol!.doc(msg.id);
          batch.set(doc, msg.toMap());
        }

        for (final item in SeedData.followUps) {
          final doc = _followupsCol!.doc(item.id);
          batch.set(doc, item.toMap());
        }

        for (final p in SeedData.partnerships) {
          final doc = _partnershipsCol!.doc(p.id);
          batch.set(doc, p.toMap());
        }

        await batch.commit();
        debugPrint('[FirestoreService] Firestore seeding complete!');
      }
    } catch (e) {
      debugPrint('[FirestoreService] Seeding error (offline or rules): $e');
    }
  }

  // -------------------------------------------------------------
  // Influencers
  // -------------------------------------------------------------

  final List<Influencer> _localInfluencers = List.from(SeedData.influencers);

  Stream<List<Influencer>> getInfluencersStream() {
    final col = _influencersCol;
    if (col == null) {
      return Stream.value(_localInfluencers);
    }
    return col
        .orderBy('fitScore', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Influencer.fromFirestore(doc))
            .toList());
  }

  Future<List<Influencer>> getInfluencers({
    String? query,
    InfluencerCategory? category,
  }) async {
    final col = _influencersCol;
    var list = <Influencer>[];

    if (col != null) {
      try {
        final snapshot = await col
            .orderBy('fitScore', descending: true)
            .get();

        list = snapshot.docs
            .map((doc) => Influencer.fromFirestore(doc))
            .toList();
      } catch (e) {
        debugPrint('[FirestoreService] getInfluencers error: $e');
      }
    }

    if (list.isEmpty) {
      list = List.from(_localInfluencers);
    }

    if (category != null && category != InfluencerCategory.highFit) {
      list = list.where((inf) => inf.category == category).toList();
    } else if (category == InfluencerCategory.highFit) {
      list = list.where((inf) => inf.fitScore >= 90).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((inf) =>
          inf.name.toLowerCase().contains(q) ||
          inf.handle.toLowerCase().contains(q) ||
          inf.niche.toLowerCase().contains(q) ||
          inf.bio.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  Future<Influencer?> getInfluencerById(String id) async {
    final col = _influencersCol;
    if (col != null) {
      try {
        final doc = await col.doc(id).get();
        if (doc.exists) {
          return Influencer.fromFirestore(doc);
        }
      } catch (e) {
        debugPrint('[FirestoreService] getInfluencerById error: $e');
      }
    }
    try {
      return _localInfluencers.firstWhere((inf) => inf.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Influencer> addInfluencer(Influencer influencer) async {
    final col = _influencersCol;
    if (col != null) {
      try {
        final docRef = col.doc(influencer.id.isEmpty ? null : influencer.id);
        final newInf = influencer.copyWith(id: docRef.id);
        await docRef.set(newInf.toMap());
        _localInfluencers.removeWhere((inf) => inf.id == newInf.id);
        _localInfluencers.insert(0, newInf);
        return newInf;
      } catch (e) {
        debugPrint('[FirestoreService] addInfluencer error: $e');
      }
    }
    _localInfluencers.removeWhere((inf) => inf.id == influencer.id);
    _localInfluencers.insert(0, influencer);
    return influencer;
  }

  Future<Influencer> updateInfluencer(Influencer updated) async {
    final col = _influencersCol;
    if (col != null) {
      try {
        await col.doc(updated.id).update(updated.toMap());
      } catch (e) {
        debugPrint('[FirestoreService] updateInfluencer error: $e');
      }
    }
    final index = _localInfluencers.indexWhere((inf) => inf.id == updated.id);
    if (index != -1) {
      _localInfluencers[index] = updated;
    }
    return updated;
  }

  // -------------------------------------------------------------
  // Outreach Messages
  // -------------------------------------------------------------

  Stream<List<OutreachMessage>> getOutreachStream() {
    final col = _outreachCol;
    if (col == null) {
      return Stream.value(SeedData.outreachMessages);
    }
    return col.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => OutreachMessage.fromFirestore(doc)).toList());
  }

  Future<List<OutreachMessage>> getMessagesByStatus(OutreachStatus status) async {
    final col = _outreachCol;
    var list = <OutreachMessage>[];

    if (col != null) {
      try {
        final snapshot = await col
            .where('status', isEqualTo: status.name)
            .get();

        list = snapshot.docs
            .map((doc) => OutreachMessage.fromFirestore(doc))
            .toList();
      } catch (e) {
        debugPrint('[FirestoreService] getMessagesByStatus error: $e');
      }
    }

    if (list.isEmpty) {
      list = SeedData.outreachMessages.where((m) => m.status == status).toList();
    }
    return list;
  }

  Future<OutreachMessage> saveDraft(OutreachMessage message) async {
    final col = _outreachCol;
    if (col != null) {
      try {
        final docRef = col.doc(message.id.isEmpty ? null : message.id);
        final finalMsg = message.copyWith(id: docRef.id);
        await docRef.set(finalMsg.toMap(), SetOptions(merge: true));
        return finalMsg;
      } catch (e) {
        debugPrint('[FirestoreService] saveDraft error: $e');
      }
    }
    return message;
  }

  Future<OutreachMessage> sendOutreach(OutreachMessage draft) async {
    final sentMessage = draft.copyWith(
      status: OutreachStatus.sent,
      approvedByUser: true,
      sentAt: DateTime.now(),
      timeAgoDisplay: 'Just now',
      gmailThreadId: 'gm_thread_${DateTime.now().millisecondsSinceEpoch}',
    );

    final col = _outreachCol;
    if (col != null) {
      try {
        await col.doc(sentMessage.id).set(sentMessage.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('[FirestoreService] sendOutreach error: $e');
      }
    }
    return sentMessage;
  }

  Future<OutreachMessage> passOutreach(String messageId) async {
    final col = _outreachCol;
    if (col != null) {
      try {
        await col.doc(messageId).update({'status': OutreachStatus.passed.name});
        final doc = await col.doc(messageId).get();
        if (doc.exists) {
          return OutreachMessage.fromFirestore(doc);
        }
      } catch (e) {
        debugPrint('[FirestoreService] passOutreach error: $e');
      }
    }
    return SeedData.outreachMessages.firstWhere((m) => m.id == messageId);
  }

  // -------------------------------------------------------------
  // Follow-ups
  // -------------------------------------------------------------

  Stream<List<FollowUpItem>> getFollowUpsStream() {
    final col = _followupsCol;
    if (col == null) {
      return Stream.value(SeedData.followUps);
    }
    return col.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => FollowUpItem.fromFirestore(doc)).toList());
  }

  Future<List<FollowUpItem>> getFollowUps() async {
    final col = _followupsCol;
    var list = <FollowUpItem>[];

    if (col != null) {
      try {
        final snapshot = await col.get();
        list = snapshot.docs.map((doc) => FollowUpItem.fromFirestore(doc)).toList();
      } catch (e) {
        debugPrint('[FirestoreService] getFollowUps error: $e');
      }
    }

    if (list.isEmpty) {
      list = List.from(SeedData.followUps);
    }
    return list;
  }

  Future<void> updateFollowUp(FollowUpItem item) async {
    final col = _followupsCol;
    if (col != null) {
      try {
        await col.doc(item.id).set(item.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('[FirestoreService] updateFollowUp error: $e');
      }
    }
  }

  // -------------------------------------------------------------
  // Partnerships & Analytics
  // -------------------------------------------------------------

  Future<List<Partnership>> getPartnerships() async {
    final col = _partnershipsCol;
    var list = <Partnership>[];

    if (col != null) {
      try {
        final snapshot = await col.orderBy('revenue', descending: true).get();
        list = snapshot.docs.map((doc) => Partnership.fromFirestore(doc)).toList();
      } catch (e) {
        debugPrint('[FirestoreService] getPartnerships error: $e');
      }
    }

    if (list.isEmpty) {
      list = List.from(SeedData.partnerships);
    }
    return list;
  }

  Future<DashboardStats> getDashboardStats() async {
    try {
      final influencers = await getInfluencers();
      final repliedMessages = await getMessagesByStatus(OutreachStatus.replied);
      final partnerships = await getPartnerships();

      final highFitCount = influencers.where((i) => i.fitScore >= 90).length;

      return DashboardStats(
        activeDeals: partnerships.length,
        pendingReplies: repliedMessages.length,
        newProspects: influencers.length,
        aiPriorityCount: highFitCount,
      );
    } catch (e) {
      return SeedData.dashboardStats;
    }
  }

  Future<List<PrioritizedActionItem>> getPrioritizedActions() async {
    try {
      final items = <PrioritizedActionItem>[];

      // 1. High-fit influencers with no outreach yet → highest priority action
      final influencers = await getInfluencers();
      final allOutreach = (await getMessagesByStatus(OutreachStatus.draft)) +
          (await getMessagesByStatus(OutreachStatus.sent)) +
          (await getMessagesByStatus(OutreachStatus.replied));
      final outreachedIds = allOutreach.map((m) => m.influencerId).toSet();
      final untouched = influencers
          .where((inf) => inf.fitScore >= 90 && !outreachedIds.contains(inf.id))
          .toList();
      for (final inf in untouched.take(3)) {
        items.add(PrioritizedActionItem(
          id: 'action_reach_${inf.id}',
          title: 'Start outreach to ${inf.name}',
          description: 'Fit Score ${inf.fitScore}% — ${inf.niche}. No contact yet.',
          buttonText: 'Draft with AI',
          actionType: 'ai_draft',
          targetId: inf.id,
          timeLabel: 'New',
        ));
      }

      // 2. Pending replies — need follow up
      final followUps = await getFollowUps();
      final pendingFollowUps = followUps
          .where((f) => f.status == FollowUpStatus.pending)
          .take(2)
          .toList();
      for (final fu in pendingFollowUps) {
        items.add(PrioritizedActionItem(
          id: 'action_followup_${fu.id}',
          title: 'Follow up with ${fu.influencerName}',
          description: '${fu.daysSinceContact} days since last contact. ${fu.waitTimeTag}',
          buttonText: 'Send Follow-up',
          actionType: 'follow_up',
          targetId: fu.influencerId,
          timeLabel: '${fu.daysSinceContact}d',
        ));
      }

      // 3. Replied messages awaiting review
      final replied = await getMessagesByStatus(OutreachStatus.replied);
      for (final msg in replied.take(2)) {
        items.add(PrioritizedActionItem(
          id: 'action_reply_${msg.id}',
          title: '${msg.influencerName} replied — review',
          description: msg.replySnippet ?? 'New reply waiting for your review.',
          buttonText: 'Review Reply',
          actionType: 'review_contract',
          targetId: msg.id,
          timeLabel: msg.timeAgoDisplay,
        ));
      }

      if (items.isEmpty) return SeedData.prioritizedActions;
      return items;
    } catch (e) {
      debugPrint('[FirestoreService] getPrioritizedActions error: $e');
      return SeedData.prioritizedActions;
    }
  }

  Future<AnalyticsOverview> getAnalyticsOverview() async {
    try {
      final partnerships = await getPartnerships();
      final sent = await getMessagesByStatus(OutreachStatus.sent);
      final replied = await getMessagesByStatus(OutreachStatus.replied);

      final responseRate = sent.isNotEmpty ? (replied.length / sent.length) * 100 : 0.0;
      final velocityData = _computeWeeklyVelocity(sent);

      return AnalyticsOverview(
        outreachSent: sent.length,
        responseRate: double.parse(responseRate.toStringAsFixed(1)),
        convertedPartners: partnerships.length,
        velocityData: velocityData.isNotEmpty ? velocityData : SeedData.analyticsOverview.velocityData,
        topPartners: partnerships.isNotEmpty ? partnerships : SeedData.analyticsOverview.topPartners,
      );
    } catch (e) {
      return SeedData.analyticsOverview;
    }
  }

  List<VelocityPoint> _computeWeeklyVelocity(List<OutreachMessage> sentMessages) {
    final Map<int, int> dayCounts = {};
    for (final msg in sentMessages) {
      if (msg.sentAt == null) continue;
      final day = msg.sentAt!.day;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    if (dayCounts.isEmpty) return [];
    final sortedDays = dayCounts.keys.toList()..sort();
    int cumSent = 0;
    return sortedDays.map((day) {
      cumSent += dayCounts[day]!;
      return VelocityPoint(day: day, sent: cumSent, converted: (cumSent * 0.12).round());
    }).toList();
  }
}