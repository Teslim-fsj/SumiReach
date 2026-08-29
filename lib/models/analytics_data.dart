import 'partnership.dart';

class VelocityPoint {
  final int day;
  final int sent;
  final int converted;

  const VelocityPoint({
    required this.day,
    required this.sent,
    required this.converted,
  });
}

class PrioritizedActionItem {
  final String id;
  final String title;
  final String description;
  final String buttonText;
  final String actionType; // 'ai_draft', 'review_contract', 'view_insights', 'follow_up'
  final String targetId;
  final String? timeLabel;

  const PrioritizedActionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.actionType,
    required this.targetId,
    this.timeLabel,
  });
}

class DashboardStats {
  final int activeDeals;
  final int pendingReplies;
  final int newProspects;
  final int aiPriorityCount;

  const DashboardStats({
    required this.activeDeals,
    required this.pendingReplies,
    required this.newProspects,
    required this.aiPriorityCount,
  });
}

class AnalyticsOverview {
  final int outreachSent;
  final double responseRate;
  final int convertedPartners;
  final List<VelocityPoint> velocityData;
  final List<Partnership> topPartners;

  const AnalyticsOverview({
    required this.outreachSent,
    required this.responseRate,
    required this.convertedPartners,
    required this.velocityData,
    required this.topPartners,
  });
}
