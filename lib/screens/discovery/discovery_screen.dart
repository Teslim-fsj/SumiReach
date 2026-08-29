import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/discovered_candidate.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/influencer_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/discovered_candidate_card.dart';
import '../../widgets/candidate_detail_modal.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    final prov = context.read<DiscoveryProvider>();
    if (prov.searchQuery.isNotEmpty) {
      _queryController.text = prov.searchQuery;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    final discoveryProv = context.read<DiscoveryProvider>();
    final infProv = context.read<InfluencerProvider>();
    discoveryProv.search(query, influencerProvider: infProv);
  }

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryProvider>();
    final infProv = context.read<InfluencerProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Discover Influencers'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              // Top Search Area Card
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find potential SumQuiz partners across the web.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Natural Language Search Input
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12, top: 14),
                            child: Icon(Icons.travel_explore, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _queryController,
                              maxLines: 2,
                              minLines: 1,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _triggerSearch(),
                              decoration: const InputDecoration(
                                hintText: 'Describe the creators you\'re looking for...',
                                hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_queryController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                              onPressed: () {
                                _queryController.clear();
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Search Button & Filters Toggle Row
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                          icon: Icon(
                            _showFilters ? Icons.filter_list_off : Icons.filter_list,
                            size: 16,
                            color: !discovery.filters.isDefault ? AppColors.primary : AppColors.textSecondary,
                          ),
                          label: Text(
                            !discovery.filters.isDefault ? 'Filters (Active)' : 'Filters',
                            style: TextStyle(
                              fontSize: 12,
                              color: !discovery.filters.isDefault ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            side: BorderSide(
                              color: !discovery.filters.isDefault ? AppColors.primary : AppColors.border,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: discovery.isSearching ? null : _triggerSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: discovery.isSearching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.search, size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Search Web',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),

                    // Optional Filter Panel
                    if (_showFilters) ...[
                      const SizedBox(height: 12),
                      _buildFiltersPanel(discovery),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),

              // Dynamic Body View based on state
              Expanded(
                child: _buildStateView(discovery, infProv),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersPanel(DiscoveryProvider discovery) {
    final filters = discovery.filters;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Platform: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              DropdownButton<String>(
                value: filters.platform,
                isDense: true,
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                underline: const SizedBox(),
                items: ['Any', 'TikTok', 'Instagram', 'YouTube', 'X', 'Blog / Website']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) discovery.updateFilters(filters.copyWith(platform: val));
                },
              ),
              const Spacer(),
              const Text('Location: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              DropdownButton<String>(
                value: filters.location,
                isDense: true,
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                underline: const SizedBox(),
                items: ['Any', 'Nigeria', 'Lagos', 'Abuja', 'Other']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) discovery.updateFilters(filters.copyWith(location: val));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Niche: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              DropdownButton<String>(
                value: filters.niche,
                isDense: true,
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                underline: const SizedBox(),
                items: ['Any', 'Education', 'JAMB', 'WAEC', 'NECO', 'Study', 'University', 'Productivity', 'Other']
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) discovery.updateFilters(filters.copyWith(niche: val));
                },
              ),
              const Spacer(),
              Row(
                children: [
                  Checkbox(
                    value: filters.hasPublicEmailOnly,
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (v) => discovery.updateFilters(filters.copyWith(hasPublicEmailOnly: v ?? false)),
                  ),
                  const Text('Email only', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          if (!filters.isDefault) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => discovery.resetFilters(),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text('Reset filters', style: TextStyle(fontSize: 11, color: AppColors.error)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStateView(DiscoveryProvider discovery, InfluencerProvider infProv) {
    switch (discovery.state) {
      case DiscoveryState.initial:
        return _buildInitialState(discovery, infProv);
      case DiscoveryState.searching:
        return _buildSearchingState(discovery);
      case DiscoveryState.results:
        return _buildResultsState(discovery, infProv);
      case DiscoveryState.empty:
        return _buildEmptyState(discovery);
      case DiscoveryState.error:
        return _buildErrorState(discovery);
    }
  }

  Widget _buildInitialState(DiscoveryProvider discovery, InfluencerProvider infProv) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Guidance Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Find your next SumQuiz partners',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Describe the type of creator you\'re looking for and search the web for potential matches. The AI engine will locate candidates, extract details, and calculate fit scores.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Recent & Suggested Discovery Searches
        const Text(
          'SUGGESTED & RECENT SEARCHES',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: discovery.searchHistory.map((query) {
            return ActionChip(
              avatar: const Icon(Icons.search, size: 14, color: AppColors.primary),
              label: Text(query, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              onPressed: () {
                _queryController.text = query;
                discovery.search(query, influencerProvider: infProv);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchingState(DiscoveryProvider discovery) {
    final steps = [
      DiscoverySearchStep.interpreting,
      DiscoverySearchStep.searching,
      DiscoverySearchStep.identifying,
      DiscoverySearchStep.qualifying,
      DiscoverySearchStep.deduplicating,
      DiscoverySearchStep.ranking,
    ];

    final currentIdx = steps.indexOf(discovery.currentStep);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              discovery.currentStep.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Scanning public web indexes and calculating creator fit...',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Stepped progress indicator list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: steps.map((step) {
                  final stepIdx = steps.indexOf(step);
                  final isDone = stepIdx < currentIdx;
                  final isCurrent = stepIdx == currentIdx;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        if (isDone)
                          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16)
                        else if (isCurrent)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        else
                          Icon(Icons.radio_button_unchecked, color: Colors.grey.shade300, size: 16),
                        const SizedBox(width: 10),
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                            color: isDone || isCurrent ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsState(DiscoveryProvider discovery, InfluencerProvider infProv) {
    final candidates = discovery.candidates;
    final selectedCount = discovery.selectedCount;

    return Column(
      children: [
        // Summary & Bulk Save Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFFF9FAFB),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${candidates.length} candidates found • ${discovery.strongMatchCount} strong matches',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (selectedCount > 0)
                ElevatedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final count = await discovery.saveSelectedCandidates(infProv);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('$count creators saved to SumiReach Influencers roster!'),
                        backgroundColor: AppColors.darkButton,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.download_done, size: 14, color: Colors.white),
                  label: Text('Save Selected ($selectedCount)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Candidate List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              final isSelected = discovery.selectedCandidateIds.contains(candidate.id);

              return DiscoveredCandidateCard(
                candidate: candidate,
                isSelected: isSelected,
                onSelectChanged: (val) => discovery.toggleCandidateSelection(candidate.id),
                onView: () {
                  CandidateDetailModal.show(
                    context,
                    candidate,
                    () async {
                      await discovery.saveSingleCandidate(candidate, infProv);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${candidate.name} saved to SumiReach roster!'),
                            backgroundColor: AppColors.darkButton,
                          ),
                        );
                      }
                    },
                  );
                },
                onSave: () async {
                  await discovery.saveSingleCandidate(candidate, infProv);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${candidate.name} added to Influencer Roster!'),
                        backgroundColor: AppColors.darkButton,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(DiscoveryProvider discovery) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'No strong matches found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try broadening your query keywords, removing strict follower limits, or selecting "Any" platform.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    discovery.resetFilters();
                    _triggerSearch();
                  },
                  child: const Text('Broaden Search'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _queryController.text = 'Nigerian student creators and exam preparation';
                    _triggerSearch();
                  },
                  child: const Text('Try Example Query'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(DiscoveryProvider discovery) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'We couldn\'t complete the web search.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              discovery.errorMessage ?? 'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _triggerSearch,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}