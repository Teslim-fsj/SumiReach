import 'package:cloud_firestore/cloud_firestore.dart';

enum FollowUpStatus {
  pending,
  sent,
  skipped;

  static FollowUpStatus fromString(String? val) {
    if (val == null) return FollowUpStatus.pending;
    return FollowUpStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.toString() == val,
      orElse: () => FollowUpStatus.pending,
    );
  }
}

class FollowUpItem {
  final String id;
  final String influencerId;
  final String influencerName;
  final String influencerHandle;
  final int avatarColorValue;
  final String email;
  final int daysSinceContact;
  final String subject;
  final String suggestedBody;
  final String waitTimeTag;
  final FollowUpStatus status;
  final DateTime scheduledDate;

  const FollowUpItem({
    required this.id,
    required this.influencerId,
    required this.influencerName,
    required this.influencerHandle,
    this.avatarColorValue = 0xFF4F46E5,
    required this.email,
    required this.daysSinceContact,
    required this.subject,
    required this.suggestedBody,
    this.waitTimeTag = 'WAIT: 3d+',
    this.status = FollowUpStatus.pending,
    required this.scheduledDate,
  });

  FollowUpItem copyWith({
    String? id,
    String? influencerId,
    String? influencerName,
    String? influencerHandle,
    int? avatarColorValue,
    String? email,
    int? daysSinceContact,
    String? subject,
    String? suggestedBody,
    String? waitTimeTag,
    FollowUpStatus? status,
    DateTime? scheduledDate,
  }) {
    return FollowUpItem(
      id: id ?? this.id,
      influencerId: influencerId ?? this.influencerId,
      influencerName: influencerName ?? this.influencerName,
      influencerHandle: influencerHandle ?? this.influencerHandle,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      email: email ?? this.email,
      daysSinceContact: daysSinceContact ?? this.daysSinceContact,
      subject: subject ?? this.subject,
      suggestedBody: suggestedBody ?? this.suggestedBody,
      waitTimeTag: waitTimeTag ?? this.waitTimeTag,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }

  factory FollowUpItem.fromMap(Map<String, dynamic> map, [String? id]) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      return DateTime.now();
    }

    return FollowUpItem(
      id: id ?? map['id']?.toString() ?? '',
      influencerId: map['influencerId']?.toString() ?? '',
      influencerName: map['influencerName']?.toString() ?? '',
      influencerHandle: map['influencerHandle']?.toString() ?? '',
      avatarColorValue: (map['avatarColorValue'] as num?)?.toInt() ?? 0xFF4F46E5,
      email: map['email']?.toString() ?? '',
      daysSinceContact: (map['daysSinceContact'] as num?)?.toInt() ?? 3,
      subject: map['subject']?.toString() ?? '',
      suggestedBody: map['suggestedBody']?.toString() ?? '',
      waitTimeTag: map['waitTimeTag']?.toString() ?? 'WAIT: 3d+',
      status: FollowUpStatus.fromString(map['status']?.toString()),
      scheduledDate: parseDate(map['scheduledDate']),
    );
  }

  factory FollowUpItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return FollowUpItem.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'influencerId': influencerId,
      'influencerName': influencerName,
      'influencerHandle': influencerHandle,
      'avatarColorValue': avatarColorValue,
      'email': email,
      'daysSinceContact': daysSinceContact,
      'subject': subject,
      'suggestedBody': suggestedBody,
      'waitTimeTag': waitTimeTag,
      'status': status.name,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
    };
  }
}