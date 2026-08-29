import 'package:cloud_firestore/cloud_firestore.dart';

enum InfluencerCategory {
  highFit,
  tech,
  lifestyle,
  design,
  finance;

  String get displayName {
    switch (this) {
      case InfluencerCategory.highFit:
        return 'High Fit (90+)';
      case InfluencerCategory.tech:
        return 'Tech & Setup';
      case InfluencerCategory.lifestyle:
        return 'Lifestyle & Study';
      case InfluencerCategory.design:
        return 'Design & Dev';
      case InfluencerCategory.finance:
        return 'Finance & Career';
    }
  }

  static InfluencerCategory fromString(String? val) {
    if (val == null) return InfluencerCategory.highFit;
    return InfluencerCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.toString() == val,
      orElse: () => InfluencerCategory.tech,
    );
  }
}

enum InfluencerStatus {
  newProspect,
  analyzing,
  qualified,
  draftReady,
  outreachSent,
  followUpDue,
  replied,
  partnered,
  passed;

  static InfluencerStatus fromString(String? val) {
    if (val == null) return InfluencerStatus.qualified;
    return InfluencerStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.toString() == val,
      orElse: () => InfluencerStatus.qualified,
    );
  }
}

class Influencer {
  final String id;
  final String name;
  final String handle;
  final String platform;
  final String? profileUrl;
  final String? profileImageUrl;
  final int avatarColorValue;
  final String email;
  final int followers;
  final String followersDisplay;
  final double engagementRate;
  final String niche;
  final InfluencerCategory category;
  final String location;
  final String bio;
  final int fitScore;
  final String fitReason;
  final int audienceOverlapPercent;
  final String strongEngagementText;
  final String brandAlignmentText;
  final InfluencerStatus status;
  final DateTime? lastContactedAt;
  final DateTime? nextFollowUpAt;
  final String notes;
  final String? referralCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Influencer({
    required this.id,
    required this.name,
    required this.handle,
    this.platform = 'Twitter/X',
    this.profileUrl,
    this.profileImageUrl,
    this.avatarColorValue = 0xFF4F46E5,
    required this.email,
    required this.followers,
    required this.followersDisplay,
    required this.engagementRate,
    required this.niche,
    required this.category,
    required this.location,
    required this.bio,
    required this.fitScore,
    required this.fitReason,
    this.audienceOverlapPercent = 75,
    this.strongEngagementText = 'Averages 5.0% ER on recent posts, above category average.',
    this.brandAlignmentText = 'Consistently advocates for productivity and modern workflows.',
    this.status = InfluencerStatus.qualified,
    this.lastContactedAt,
    this.nextFollowUpAt,
    this.notes = '',
    this.referralCode,
    required this.createdAt,
    required this.updatedAt,
  });

  Influencer copyWith({
    String? id,
    String? name,
    String? handle,
    String? platform,
    String? profileUrl,
    String? profileImageUrl,
    int? avatarColorValue,
    String? email,
    int? followers,
    String? followersDisplay,
    double? engagementRate,
    String? niche,
    InfluencerCategory? category,
    String? location,
    String? bio,
    int? fitScore,
    String? fitReason,
    int? audienceOverlapPercent,
    String? strongEngagementText,
    String? brandAlignmentText,
    InfluencerStatus? status,
    DateTime? lastContactedAt,
    DateTime? nextFollowUpAt,
    String? notes,
    String? referralCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Influencer(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      platform: platform ?? this.platform,
      profileUrl: profileUrl ?? this.profileUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      email: email ?? this.email,
      followers: followers ?? this.followers,
      followersDisplay: followersDisplay ?? this.followersDisplay,
      engagementRate: engagementRate ?? this.engagementRate,
      niche: niche ?? this.niche,
      category: category ?? this.category,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      fitScore: fitScore ?? this.fitScore,
      fitReason: fitReason ?? this.fitReason,
      audienceOverlapPercent: audienceOverlapPercent ?? this.audienceOverlapPercent,
      strongEngagementText: strongEngagementText ?? this.strongEngagementText,
      brandAlignmentText: brandAlignmentText ?? this.brandAlignmentText,
      status: status ?? this.status,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      nextFollowUpAt: nextFollowUpAt ?? this.nextFollowUpAt,
      notes: notes ?? this.notes,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Influencer.fromMap(Map<String, dynamic> map, [String? id]) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      return DateTime.now();
    }

    DateTime? parseOptionalDate(dynamic d) {
      if (d == null) return null;
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d);
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      return null;
    }

    return Influencer(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      handle: map['handle']?.toString() ?? '',
      platform: map['platform']?.toString() ?? 'Twitter/X',
      profileUrl: map['profileUrl']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      avatarColorValue: (map['avatarColorValue'] as num?)?.toInt() ?? 0xFF4F46E5,
      email: map['email']?.toString() ?? '',
      followers: (map['followers'] as num?)?.toInt() ?? 0,
      followersDisplay: map['followersDisplay']?.toString() ?? '0',
      engagementRate: (map['engagementRate'] as num?)?.toDouble() ?? 0.0,
      niche: map['niche']?.toString() ?? '',
      category: InfluencerCategory.fromString(map['category']?.toString()),
      location: map['location']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      fitScore: (map['fitScore'] as num?)?.toInt() ?? 0,
      fitReason: map['fitReason']?.toString() ?? '',
      audienceOverlapPercent: (map['audienceOverlapPercent'] as num?)?.toInt() ?? 75,
      strongEngagementText: map['strongEngagementText']?.toString() ?? 'Averages 5.0% ER on recent posts.',
      brandAlignmentText: map['brandAlignmentText']?.toString() ?? 'Consistently advocates for productivity.',
      status: InfluencerStatus.fromString(map['status']?.toString()),
      lastContactedAt: parseOptionalDate(map['lastContactedAt']),
      nextFollowUpAt: parseOptionalDate(map['nextFollowUpAt']),
      notes: map['notes']?.toString() ?? '',
      referralCode: map['referralCode']?.toString(),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  factory Influencer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Influencer.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'handle': handle,
      'platform': platform,
      'profileUrl': profileUrl,
      'profileImageUrl': profileImageUrl,
      'avatarColorValue': avatarColorValue,
      'email': email,
      'followers': followers,
      'followersDisplay': followersDisplay,
      'engagementRate': engagementRate,
      'niche': niche,
      'category': category.name,
      'location': location,
      'bio': bio,
      'fitScore': fitScore,
      'fitReason': fitReason,
      'audienceOverlapPercent': audienceOverlapPercent,
      'strongEngagementText': strongEngagementText,
      'brandAlignmentText': brandAlignmentText,
      'status': status.name,
      'lastContactedAt': lastContactedAt != null ? Timestamp.fromDate(lastContactedAt!) : null,
      'nextFollowUpAt': nextFollowUpAt != null ? Timestamp.fromDate(nextFollowUpAt!) : null,
      'notes': notes,
      'referralCode': referralCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}