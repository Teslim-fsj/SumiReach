import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/creator_avatar.dart';
import '../../widgets/app_logo.dart';
import '../../providers/integrations_provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../influencers/influencers_screen.dart';
import '../outreach/outreach_screen.dart';
import '../insights/insights_screen.dart';
import '../followups/followups_screen.dart';
import '../settings/settings_screen.dart';
import '../discovery/discovery_screen.dart';

class AppShell extends StatefulWidget {
  final int initialTab;
  const AppShell({super.key, this.initialTab = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    InfluencersScreen(),
    OutreachScreen(),
    InsightsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final integrations = context.watch<IntegrationsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 24),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      AppLogo(size: 26, borderRadius: 6),
                      SizedBox(width: 8),
                      Text(
                        'SumiReach',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: CreatorAvatar(
                      name: auth.userDisplayName,
                      size: 32,
                      isCircle: true,
                      colorValue: 0xFF1E293B,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const AppLogo(size: 40, borderRadius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.userDisplayName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            auth.userEmail,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.grid_view, color: AppColors.textPrimary),
                title: const Text('Dashboard'),
                selected: _currentIndex == 0,
                onTap: () {
                  _onTabTapped(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_outline, color: AppColors.textPrimary),
                title: const Text('Influencers Roster'),
                selected: _currentIndex == 1,
                onTap: () {
                  _onTabTapped(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.travel_explore_rounded, color: AppColors.primary),
                title: Row(
                  children: [
                    const Text('Discover Influencers', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'WEB AI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryPurpleText,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.call_split, color: AppColors.textPrimary),
                title: const Text('Outreach Pipeline'),
                selected: _currentIndex == 2,
                onTap: () {
                  _onTabTapped(2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: AppColors.textPrimary),
                title: const Text('Follow-up Queue'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FollowupsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: AppColors.textPrimary),
                title: const Text('Acquisition Insights'),
                selected: _currentIndex == 3,
                onTap: () {
                  _onTabTapped(3);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'INTEGRATIONS & SYNC',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined, color: Color(0xFF0F9D58)),
                title: const Text('Google Sheets'),
                subtitle: Text(
                  integrations.sheetName,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline, color: Color(0xFFEA4335)),
                title: const Text('Gmail Sync'),
                subtitle: Text(
                  integrations.gmailAccount,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const Spacer(),
              if (auth.isAuthenticated)
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.textSecondary, size: 20),
                  title: const Text('Sign Out', style: TextStyle(fontSize: 14)),
                  onTap: () async {
                    await auth.signOut();
                    if (context.mounted) Navigator.pop(context);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.login, color: AppColors.primary, size: 20),
                  title: const Text('Sign in with Google', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  onTap: () async {
                    Navigator.pop(context);
                    await auth.signInWithGoogle();
                  },
                ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Text(
                      'SumiReach v1.0 • SumQuiz Internal',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Dashboard'),
                _buildNavItem(1, Icons.people_alt_outlined, 'Influencers'),
                _buildNavItem(2, Icons.call_split_rounded, 'Outreach'),
                _buildNavItem(3, Icons.bar_chart_rounded, 'Insights'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.navInactive;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}