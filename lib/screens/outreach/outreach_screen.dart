import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/outreach.dart';
import '../../providers/outreach_provider.dart';
import '../../widgets/pipeline_message_tile.dart';
import '../../widgets/empty_state.dart';
import 'outreach_detail_screen.dart';

class OutreachScreen extends StatefulWidget {
  const OutreachScreen({super.key});

  @override
  State<OutreachScreen> createState() => _OutreachScreenState();
}

class _OutreachScreenState extends State<OutreachScreen> {
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OutreachProvider>();

    return Column(
      children: [
        // Screen Header: "Pipeline" + Search icon (exact match to Screen 4)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_isSearching)
                const Text(
                  'Pipeline',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                )
              else
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    onChanged: (v) => provider.setSearchQuery(v),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search pipeline messages...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() => _isSearching = false);
                          _searchCtrl.clear();
                          provider.setSearchQuery('');
                        },
                      ),
                    ),
                  ),
                ),
              if (!_isSearching)
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.textPrimary, size: 24),
                  onPressed: () => setState(() => _isSearching = true),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),

        // Segmented Tab Bar [Drafts | Sent | Replied | Passed]
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                _buildSegmentTab(
                  label: 'Drafts',
                  status: OutreachStatus.draft,
                  selected: provider.selectedTab == OutreachStatus.draft,
                  onTap: () => provider.setSelectedTab(OutreachStatus.draft),
                ),
                _buildSegmentTab(
                  label: 'Sent',
                  status: OutreachStatus.sent,
                  selected: provider.selectedTab == OutreachStatus.sent,
                  onTap: () => provider.setSelectedTab(OutreachStatus.sent),
                ),
                _buildSegmentTab(
                  label: 'Replied',
                  status: OutreachStatus.replied,
                  selected: provider.selectedTab == OutreachStatus.replied,
                  onTap: () => provider.setSelectedTab(OutreachStatus.replied),
                ),
                _buildSegmentTab(
                  label: 'Passed',
                  status: OutreachStatus.passed,
                  selected: provider.selectedTab == OutreachStatus.passed,
                  onTap: () => provider.setSelectedTab(OutreachStatus.passed),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.border),

        // Message List
        Expanded(
          child: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : provider.messages.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.inbox_outlined,
                      title: 'No ${provider.selectedTab.name} messages',
                      description: 'Outreach messages in this stage will appear here.',
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchMessages(),
                      color: AppColors.primary,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: provider.messages.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.border,
                        ),
                        itemBuilder: (context, index) {
                          final msg = provider.messages[index];
                          return PipelineMessageTile(
                            message: msg,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OutreachDetailScreen(message: msg),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSegmentTab({
    required String label,
    required OutreachStatus status,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: selected ? Border.all(color: AppColors.borderSubtle, width: 1) : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.primaryPurpleText : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
