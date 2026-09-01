import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/influencer_provider.dart';
import '../../widgets/filter_chip_row.dart';
import '../../widgets/influencer_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/add_influencer_sheet.dart';
import 'influencer_detail_screen.dart';
import '../discovery/discovery_screen.dart';

class InfluencersScreen extends StatefulWidget {
  const InfluencersScreen({super.key});

  @override
  State<InfluencersScreen> createState() => _InfluencersScreenState();
}

class _InfluencersScreenState extends State<InfluencersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InfluencerProvider>();

    return Stack(
      children: [
        Column(
          children: [
            // Search bar + Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => provider.setSearchQuery(val),
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Search creators...',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Discover Influencers on the Web',
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.scoreHighBorder),
                        ),
                        child: const Icon(
                          Icons.travel_explore_rounded,
                          color: AppColors.primaryPurpleText,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Add New Creator',
                    child: InkWell(
                      onTap: () => AddInfluencerSheet.show(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips row
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilterChipRow(
                selectedCategory: provider.selectedCategory,
                onSelected: (cat) => provider.setCategory(cat),
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // Influencers list
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : provider.influencers.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.search_off,
                          title: 'No creators found',
                          description: 'Try adjusting your search or add a new creator manually.',
                          actionLabel: 'Add Creator',
                          onAction: () => AddInfluencerSheet.show(context),
                        )
                      : RefreshIndicator(
                          onRefresh: () => provider.fetchInfluencers(),
                          color: AppColors.primary,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: provider.influencers.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.border,
                            ),
                            itemBuilder: (context, index) {
                              final inf = provider.influencers[index];
                              return InfluencerTile(
                                influencer: inf,
                                onTap: () {
                                  provider.selectInfluencer(inf.id);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => InfluencerDetailScreen(influencerId: inf.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => AddInfluencerSheet.show(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Add Creator',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}