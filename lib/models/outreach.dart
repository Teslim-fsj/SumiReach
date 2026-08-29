import 'package:cloud_firestore/cloud_firestore.dart';

enum OutreachStatus {
  draft,
  sent,
  replied,
  passed;

  static OutreachStatus fromString(String? val) {
    if (val == null) return OutreachStatus.draft;
    return OutreachStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.toString() == val,
      orElse: () => OutreachStatus.draft,
    );
  }
}

class OutreachMessage {
  final String id;
  final String influencerId;
  final String influencerName;
  final String influencerHandle;
  final int avatarColorValue;
  final String recipientEmail;
  final String subject;
  final String body;
  final OutreachStatus status;
  final bool generatedByAi;
  final bool approvedByUser;
  final DateTime? sentAt;
  final DateTime? followUpAt;
  final DateTime? repliedAt;
  final String? timeAgoDisplay;
  final String? gmailThreadId;
  final String? replySnippet;

  const OutreachMessage({
    required this.id,
    required this.influencerId,
    required this.influencerName,
    required this.influencerHandle,
    this.avatarColorValue = 0xFF4F46E5,
    required this.recipientEmail,
    required this.subject,
    required this.body,
    required this.status,
    this.generatedByAi = true,
    this.approvedByUser = false,
    this.sentAt,
    this.followUpAt,
    this.repliedAt,
    this.timeAgoDisplay,
    this.gmailThreadId,
    this.replySnippet,
  });

  OutreachMessage copyWith({
    String? id,
    String? influencerId,
    String? influencerName,
    String? influencerHandle,
    int? avatarColorValue,
    String? recipientEmail,
    String? subject,
    String? body,
    OutreachStatus? status,
    bool? generatedByAi,
    bool? approvedByUser,
    DateTime? sentAt,
    DateTime? followUpAt,
    DateTime? repliedAt,
    String? timeAgoDisplay,
    String? gmailThreadId,
    String? replySnippet,
  }) {
    return OutreachMessage(
      id: id ?? this.id,
      influencerId: influencerId ?? this.influencerId,
      influencerName: influencerName ?? this.influencerName,
      influencerHandle: influencerHandle ?? this.influencerHandle,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      status: status ?? this.status,
      generatedByAi: generatedByAi ?? this.generatedByAi,
      approvedByUser: approvedByUser ?? this.approvedByUser,
      sentAt: sentAt ?? this.sentAt,
      followUpAt: followUpAt ?? this.followUpAt,
      repliedAt: repliedAt ?? this.repliedAt,
      timeAgoDisplay: timeAgoDisplay ?? this.timeAgoDisplay,
      gmailThreadId: gmailThreadId ?? this.gmailThreadId,
      replySnippet: replySnippet ?? this.replySnippet,
    );
  }

  factory OutreachMessage.fromMap(Map<String, dynamic> map, [String? id]) {
    DateTime? parseOptionalDate(dynamic d) {
      if (d == null) return null;
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d);
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      return null;
    }

    return OutreachMessage(
      id: id ?? map['id']?.toString() ?? '',
      influencerId: map['influencerId']?.toString() ?? '',
      influencerName: map['influencerName']?.toString() ?? '',
      influencerHandle: map['influencerHandle']?.toString() ?? '',
      avatarColorValue: (map['avatarColorValue'] as num?)?.toInt() ?? 0xFF4F46E5,
      recipientEmail: map['recipientEmail']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      status: OutreachStatus.fromString(map['status']?.toString()),
      generatedByAi: map['generatedByAi'] == true,
      approvedByUser: map['approvedByUser'] == true,
      sentAt: parseOptionalDate(map['sentAt']),
      followUpAt: parseOptionalDate(map['followUpAt']),
      repliedAt: parseOptionalDate(map['repliedAt']),
      timeAgoDisplay: map['timeAgoDisplay']?.toString(),
      gmailThreadId: map['gmailThreadId']?.toString(),
      replySnippet: map['replySnippet']?.toString(),
    );
  }

  factory OutreachMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return OutreachMessage.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'influencerId': influencerId,
      'influencerName': influencerName,
      'influencerHandle': influencerHandle,
      'avatarColorValue': avatarColorValue,
      'recipientEmail': recipientEmail,
      'subject': subject,
      'body': body,
      'status': status.name,
      'generatedByAi': generatedByAi,
      'approvedByUser': approvedByUser,
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'followUpAt': followUpAt != null ? Timestamp.fromDate(followUpAt!) : null,
      'repliedAt': repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
      'timeAgoDisplay': timeAgoDisplay,
      'gmailThreadId': gmailThreadId,
      'replySnippet': replySnippet,
    };
  }
}