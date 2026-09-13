import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/campaign_provider.dart';
import '../../common/custom_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaignProvider = context.watch<CampaignProvider>();
    final auth = context.watch<AuthProvider>();
    final campaigns = campaignProvider.campaigns;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Console'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            auth.switchRole('consumer');
            context.go('/home');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Campaign Moderation'),
            Tab(text: 'Platform Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Moderation
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            itemCount: campaigns.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = campaigns[index];
              return CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c.product?.brand ?? 'Brand', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('VERIFIED', style: AppTypography.labelSmall.copyWith(color: AppColors.secondaryDark, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(c.title, style: AppTypography.headlineSmall),
                    const SizedBox(height: 4),
                    Text('Model: ${c.product?.modelAssetPath ?? "assets/models/shoe.glb"}', style: AppTypography.bodySmall),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Flagged "${c.title}" for review')),
                            );
                          },
                          child: const Text('Flag', style: TextStyle(color: AppColors.error)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/ar-view/${c.id}');
                          },
                          child: const Text('Inspect in AR'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Tab 2: Users
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            children: [
              _buildUserTile('Alex Rivers', 'alex.explorer@arvision.app', 'Consumer', true),
              const SizedBox(height: 10),
              _buildUserTile('Aura Tech Official', 'brands@auratech.com', 'Advertiser', true),
              const SizedBox(height: 10),
              _buildUserTile('Strato Athletics', 'campaigns@strato.io', 'Advertiser', true),
              const SizedBox(height: 10),
              _buildUserTile('System Superadmin', 'admin@arvision.internal', 'Admin', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(String name, String email, String role, bool isActive) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Text(name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.labelLarge),
                Text(email, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'Admin' ? AppColors.accentLight : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(role, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
