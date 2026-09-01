import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/influencer.dart';
import '../providers/influencer_provider.dart';
import '../theme/app_colors.dart';

class AddInfluencerSheet extends StatefulWidget {
  const AddInfluencerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddInfluencerSheet(),
    );
  }

  @override
  State<AddInfluencerSheet> createState() => _AddInfluencerSheetState();
}

class _AddInfluencerSheetState extends State<AddInfluencerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _handleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nicheCtrl = TextEditingController();
  final _followersCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  InfluencerCategory _category = InfluencerCategory.tech;
  String _platform = 'YouTube';
  bool _isSubmitting = false;

  final List<String> _platforms = [
    'YouTube',
    'TikTok',
    'Instagram',
    'X/Twitter',
    'LinkedIn',
    'Podcast',
    'Blog/Web',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _handleCtrl.dispose();
    _emailCtrl.dispose();
    _nicheCtrl.dispose();
    _followersCtrl.dispose();
    _locationCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  String _formatFollowers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final followersInt = int.tryParse(_followersCtrl.text.trim()) ?? 10000;
    final handle = _handleCtrl.text.trim().startsWith('@')
        ? _handleCtrl.text.trim()
        : '@${_handleCtrl.text.trim()}';

    final newInfluencer = Influencer(
      id: 'inf_custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      handle: handle,
      platform: _platform,
      email: _emailCtrl.text.trim(),
      followers: followersInt,
      followersDisplay: _formatFollowers(followersInt),
      engagementRate: 4.5,
      niche: _nicheCtrl.text.trim().isNotEmpty
          ? _nicheCtrl.text.trim()
          : 'Content Creator',
      category: _category,
      location: _locationCtrl.text.trim().isNotEmpty
          ? _locationCtrl.text.trim()
          : 'Global',
      bio: _bioCtrl.text.trim().isNotEmpty
          ? _bioCtrl.text.trim()
          : 'Content creator in ${_category.displayName}.',
      fitScore: 88,
      fitReason: 'Direct manual addition. Good potential reach for SumQuiz study workflows.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: InfluencerStatus.qualified,
    );

    try {
      await context.read<InfluencerProvider>().addInfluencer(newInfluencer);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newInfluencer.name} added to your roster!'),
            backgroundColor: AppColors.darkButton,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add creator: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Creator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g. Maya Lin',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _handleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Handle *',
                          hintText: '@handle',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty) ? 'Enter handle' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _platform,
                        decoration: const InputDecoration(
                          labelText: 'Platform',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: _platforms
                            .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _platform = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Contact Email *',
                    hintText: 'creator@example.com',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter an email';
                    if (!val.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<InfluencerCategory>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: InfluencerCategory.values
                            .where((c) => c != InfluencerCategory.highFit)
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.displayName, style: const TextStyle(fontSize: 12)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _followersCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Followers',
                          hintText: 'e.g. 25000',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nicheCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Niche / Topics',
                          hintText: 'e.g. Tech & Coding',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _locationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'e.g. Lagos, NG',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Bio / Notes',
                    hintText: 'Short description of what they create...',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Add Creator to Roster',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}