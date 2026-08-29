import 'influencer.dart';

class CandidateSource {
  final String title;
  final String url;
  final String sourceType;

  const CandidateSource({
    required this.title,
    required this.url,
    required this.sourceType,
  });

  factory CandidateSource.fromMap(Map<String, dynamic> map) {
    return CandidateSource(
      title: map['title']?.toString() ?? 'Web Source',
      url: map['url']?.toString() ?? '',
      sourceType: map['sourceType']?.toString() ?? 'Website',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'sourceType': sourceType,
    };
  }
}

enum DiscoverySearchStep {
  interpreting,
  searching,
  identifying,
  qualifying,
  deduplicating,
  ranking,
  completed;

  String get label {
    switch (this) {
      case DiscoverySearchStep.interpreting:
        return 'Understanding your search';
      case DiscoverySearchStep.searching:
        return 'Searching the web';
      case DiscoverySearchStep.identifying:
        return 'Finding creators';
      case DiscoverySearchStep.qualifying:
        return 'Checking relevance';
      case DiscoverySearchStep.deduplicating:
        return 'Removing duplicates';
      case DiscoverySearchStep.ranking:
        return 'Ranking candidates';
      case DiscoverySearchStep.completed:
        return 'Discovery complete';
    }
  }
}

class DiscoveryFilters {
  final String platform;
  final String location;
  final String niche;
  final int? followerMin;
  final int? followerMax;
  final bool hasPublicEmailOnly;

  const DiscoveryFilters({
    this.platform = 'Any',
    this.location = 'Any',
    this.niche = 'Any',
    this.followerMin,
    this.followerMax,
    this.hasPublicEmailOnly = false,
  });

  DiscoveryFilters copyWith({
    String? platform,
    String? location,
    String? niche,
    int? followerMin,
    int? followerMax,
    bool? hasPublicEmailOnly,
  }) {
    return DiscoveryFilters(
      platform: platform ?? this.platform,
      location: location ?? this.location,
      niche: niche ?? this.niche,
      followerMin: followerMin ?? this.followerMin,
      followerMax: followerMax ?? this.followerMax,
      hasPublicEmailOnly: hasPublicEmailOnly ?? this.hasPublicEmailOnly,
    );
  }

  bool get isDefault =>
      platform == 'Any' &&
      location == 'Any' &&
      niche == 'Any' &&
      followerMin == null &&
      followerMax == null &&
      !hasPublicEmailOnly;
}

class DiscoveredCandidate {
  final String id;
  final String name;
  final String handle;
  final String platform;
  final String? profileUrl;
  final String? profileImageUrl;
  final int avatarColorValue;
  final int? followers;
  final String followersDisplay;
  final double engagementRate;
  final String niche;
  final InfluencerCategory category;
  final String location;
  final String? email;
  final bool hasPublicEmail;
  final String? website;
  final String bio;
  final String relevantContent;
  final int fitScore;
  final String fitReason;
  final int audienceOverlapPercent;
  final String strongEngagementText;
  final String brandAlignmentText;
  final List<CandidateSource> sources;
  final bool isSaved;
  final String? existingInfluencerId;

  const DiscoveredCandidate({
    required this.id,
    required this.name,
    required this.handle,
    required this.platform,
    this.profileUrl,
    this.profileImageUrl,
    this.avatarColorValue = 0xFF6C47FF,
    this.followers,
    this.followersDisplay = 'Unknown',
    this.engagementRate = 0.0,
    required this.niche,
    this.category = InfluencerCategory.lifestyle,
    this.location = 'Unknown',
    this.email,
    this.hasPublicEmail = false,
    this.website,
    required this.bio,
    this.relevantContent = '',
    required this.fitScore,
    required this.fitReason,
    this.audienceOverlapPercent = 75,
    this.strongEngagementText = 'Good engagement across educational & student posts.',
    this.brandAlignmentText = 'Creates content directly relevant to student learning.',
    this.sources = const [],
    this.isSaved = false,
    this.existingInfluencerId,
  });

  DiscoveredCandidate copyWith({
    String? id,
    String? name,
    String? handle,
    String? platform,
    String? profileUrl,
    String? profileImageUrl,
    int? avatarColorValue,
    int? followers,
    String? followersDisplay,
    double? engagementRate,
    String? niche,
    InfluencerCategory? category,
    String? location,
    String? email,
    bool? hasPublicEmail,
    String? website,
    String? bio,
    String? relevantContent,
    int? fitScore,
    String? fitReason,
    int? audienceOverlapPercent,
    String? strongEngagementText,
    String? brandAlignmentText,
    List<CandidateSource>? sources,
    bool? isSaved,
    String? existingInfluencerId,
  }) {
    return DiscoveredCandidate(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      platform: platform ?? this.platform,
      profileUrl: profileUrl ?? this.profileUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      followers: followers ?? this.followers,
      followersDisplay: followersDisplay ?? this.followersDisplay,
      engagementRate: engagementRate ?? this.engagementRate,
      niche: niche ?? this.niche,
      category: category ?? this.category,
      location: location ?? this.location,
      email: email ?? this.email,
      hasPublicEmail: hasPublicEmail ?? this.hasPublicEmail,
      website: website ?? this.website,
      bio: bio ?? this.bio,
      relevantContent: relevantContent ?? this.relevantContent,
      fitScore: fitScore ?? this.fitScore,
      fitReason: fitReason ?? this.fitReason,
      audienceOverlapPercent: audienceOverlapPercent ?? this.audienceOverlapPercent,
      strongEngagementText: strongEngagementText ?? this.strongEngagementText,
      brandAlignmentText: brandAlignmentText ?? this.brandAlignmentText,
      sources: sources ?? this.sources,
      isSaved: isSaved ?? this.isSaved,
      existingInfluencerId: existingInfluencerId ?? this.existingInfluencerId,
    );
  }

  /// Converts this discovered candidate into the standard SumiReach Influencer model.
  Influencer toInfluencer() {
    return Influencer(
      id: existingInfluencerId ?? 'inf_${DateTime.now().millisecondsSinceEpoch}_${handle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
      name: name,
      handle: handle.startsWith('@') ? handle : '@$handle',
      platform: platform,
      profileUrl: profileUrl,
      profileImageUrl: profileImageUrl,
      avatarColorValue: avatarColorValue,
      email: email ?? (hasPublicEmail ? email! : ''),
      followers: followers ?? 0,
      followersDisplay: followersDisplay,
      engagementRate: engagementRate,
      niche: niche,
      category: category,
      location: location,
      bio: bio,
      fitScore: fitScore,
      fitReason: fitReason,
      audienceOverlapPercent: audienceOverlapPercent,
      strongEngagementText: strongEngagementText,
      brandAlignmentText: brandAlignmentText,
      status: InfluencerStatus.newProspect,
      notes: 'Discovered via Web Search.\nSources:\n${sources.map((s) => '- ${s.title}: ${s.url}').join('\n')}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory DiscoveredCandidate.fromMap(Map<String, dynamic> map, [String? id]) {
    final sourcesList = (map['sources'] as List<dynamic>?)
            ?.map((s) => CandidateSource.fromMap(s as Map<String, dynamic>))
            .toList() ??
        [];

    final emailStr = map['email']?.toString();
    final hasEmail = emailStr != null &&
        emailStr.isNotEmpty &&
        emailStr.toLowerCase() != 'null' &&
        emailStr.toLowerCase() != 'unknown' &&
        emailStr.toLowerCase() != 'not found';

    return DiscoveredCandidate(
      id: id ?? map['id']?.toString() ?? 'cand_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name']?.toString() ?? 'Unknown Creator',
      handle: map['handle']?.toString() ?? '@creator',
      platform: map['platform']?.toString() ?? 'TikTok',
      profileUrl: map['profileUrl']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      avatarColorValue: (map['avatarColorValue'] as num?)?.toInt() ?? 0xFF6C47FF,
      followers: (map['followers'] as num?)?.toInt(),
      followersDisplay: map['followersDisplay']?.toString() ??
          (map['followers'] != null ? '${((map['followers'] as num) / 1000).toStringAsFixed(1)}K' : 'Unknown'),
      engagementRate: (map['engagementRate'] as num?)?.toDouble() ?? 4.5,
      niche: map['niche']?.toString() ?? 'Education',
      category: InfluencerCategory.fromString(map['category']?.toString()),
      location: map['location']?.toString() ?? 'Nigeria',
      email: hasEmail ? emailStr : null,
      hasPublicEmail: hasEmail,
      website: map['website']?.toString(),
      bio: map['bio']?.toString() ?? '',
      relevantContent: map['relevantContent']?.toString() ?? '',
      fitScore: (map['fitScore'] as num?)?.toInt() ?? 85,
      fitReason: map['fitReason']?.toString() ?? 'Discovered based on educational content match.',
      audienceOverlapPercent: (map['audienceOverlapPercent'] as num?)?.toInt() ?? 80,
      strongEngagementText: map['strongEngagementText']?.toString() ?? 'Consistent educational engagement.',
      brandAlignmentText: map['brandAlignmentText']?.toString() ?? 'Aligned with student learning workflows.',
      sources: sourcesList,
      isSaved: map['isSaved'] == true,
      existingInfluencerId: map['existingInfluencerId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'handle': handle,
      'platform': platform,
      'profileUrl': profileUrl,
      'profileImageUrl': profileImageUrl,
      'avatarColorValue': avatarColorValue,
      'followers': followers,
      'followersDisplay': followersDisplay,
      'engagementRate': engagementRate,
      'niche': niche,
      'category': category.name,
      'location': location,
      'email': email,
      'hasPublicEmail': hasPublicEmail,
      'website': website,
      'bio': bio,
      'relevantContent': relevantContent,
      'fitScore': fitScore,
      'fitReason': fitReason,
      'audienceOverlapPercent': audienceOverlapPercent,
      'strongEngagementText': strongEngagementText,
      'brandAlignmentText': brandAlignmentText,
      'sources': sources.map((s) => s.toMap()).toList(),
      'isSaved': isSaved,
      'existingInfluencerId': existingInfluencerId,
    };
  }
}