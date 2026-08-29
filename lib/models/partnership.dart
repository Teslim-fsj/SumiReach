import 'package:cloud_firestore/cloud_firestore.dart';

class Partnership {
  final String id;
  final String influencerId;
  final String influencerName;
  final String influencerHandle;
  final int avatarColorValue;
  final String referralCode;
  final String referralLink;
  final int signups;
  final int activatedUsers;
  final int paidUsers;
  final double revenue;
  final double commission;
  final double conversionRate;
  final int rank;
  final String status;

  const Partnership({
    required this.id,
    required this.influencerId,
    required this.influencerName,
    required this.influencerHandle,
    this.avatarColorValue = 0xFF4F46E5,
    required this.referralCode,
    required this.referralLink,
    required this.signups,
    required this.activatedUsers,
    required this.paidUsers,
    required this.revenue,
    required this.commission,
    required this.conversionRate,
    required this.rank,
    this.status = 'active',
  });

  factory Partnership.fromMap(Map<String, dynamic> map, [String? id]) {
    return Partnership(
      id: id ?? map['id']?.toString() ?? '',
      influencerId: map['influencerId']?.toString() ?? '',
      influencerName: map['influencerName']?.toString() ?? '',
      influencerHandle: map['influencerHandle']?.toString() ?? '',
      avatarColorValue: (map['avatarColorValue'] as num?)?.toInt() ?? 0xFF4F46E5,
      referralCode: map['referralCode']?.toString() ?? '',
      referralLink: map['referralLink']?.toString() ?? '',
      signups: (map['signups'] as num?)?.toInt() ?? 0,
      activatedUsers: (map['activatedUsers'] as num?)?.toInt() ?? 0,
      paidUsers: (map['paidUsers'] as num?)?.toInt() ?? 0,
      revenue: (map['revenue'] as num?)?.toDouble() ?? 0.0,
      commission: (map['commission'] as num?)?.toDouble() ?? 0.0,
      conversionRate: (map['conversionRate'] as num?)?.toDouble() ?? 0.0,
      rank: (map['rank'] as num?)?.toInt() ?? 1,
      status: map['status']?.toString() ?? 'active',
    );
  }

  factory Partnership.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Partnership.fromMap(doc.data() ?? {}, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'influencerId': influencerId,
      'influencerName': influencerName,
      'influencerHandle': influencerHandle,
      'avatarColorValue': avatarColorValue,
      'referralCode': referralCode,
      'referralLink': referralLink,
      'signups': signups,
      'activatedUsers': activatedUsers,
      'paidUsers': paidUsers,
      'revenue': revenue,
      'commission': commission,
      'conversionRate': conversionRate,
      'rank': rank,
      'status': status,
    };
  }
}