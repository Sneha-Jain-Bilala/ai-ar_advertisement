import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/groq_service.dart';
import '../../common/custom_button.dart';
import '../../common/custom_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final groqService = GroqService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            CustomCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      (user?.displayName.isNotEmpty ?? false) ? user!.displayName[0].toUpperCase() : 'A',
                      style: AppTypography.headlineLarge.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.displayName ?? 'Alex Rivers', style: AppTypography.headlineMedium),
                        const SizedBox(height: 2),
                        Text(user?.email ?? 'alex@arvision.app', style: AppTypography.bodySmall),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user?.role.toUpperCase() ?? 'CONSUMER',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Role Switcher Panel
            Text('Switch Role / Mode', style: AppTypography.headlineMedium),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.explore_rounded, color: AppColors.primary),
                    title: const Text('Consumer / Explorer View'),
                    subtitle: const Text('Scan QR ads, browse feed, experience 3D AR'),
                    trailing: auth.isConsumer
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      auth.switchRole('consumer');
                      context.go('/home');
                    },
                  ),
                  const Divider(color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.campaign_rounded, color: AppColors.secondaryDark),
                    title: const Text('Advertiser / Brand View'),
                    subtitle: const Text('Create campaigns, monitor scans, manage 3D catalog'),
                    trailing: auth.isAdvertiser
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.secondaryDark)
                        : null,
                    onTap: () {
                      auth.switchRole('advertiser');
                      context.go('/advertiser');
                    },
                  ),
                  const Divider(color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.accentDark),
                    title: const Text('Administrator View'),
                    subtitle: const Text('Platform governance, moderation, system metrics'),
                    trailing: auth.isAdmin
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.accentDark)
                        : null,
                    onTap: () {
                      auth.switchRole('admin');
                      context.go('/admin');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // System Status Card
            Text('System & AI Status', style: AppTypography.headlineMedium),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Groq Llama 3 AI:'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: groqService.isConfigured ? AppColors.secondaryLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          groqService.isConfigured ? 'Active (.env)' : 'Missing Key',
                          style: TextStyle(
                            color: groqService.isConfigured ? AppColors.secondaryDark : AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('3D AR Engine:'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'flutter_sceneview 4.35',
                          style: TextStyle(
                            color: AppColors.secondaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Sign Out
            CustomButton(
              text: 'Log Out',
              isOutlined: true,
              icon: Icons.logout_rounded,
              textColor: AppColors.error,
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
