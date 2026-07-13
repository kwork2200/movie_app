import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_values.dart';
import '../views/about_app_view.dart';
import '../views/privacy_policy_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: const Color(0xFF0F1422),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppPadding.p24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.movie_creation_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSize.s12),
                  Text(
                    'Movie App',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    'Discover Movies & TV Shows',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSize.s16),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
                children: [
                  _DrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About App',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutAppView(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyView(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Version at bottom
            Container(
              padding: const EdgeInsets.all(AppPadding.p16),
              child: Column(
                children: [
                  const Divider(color: AppColors.secondaryText, height: 1),
                  const SizedBox(height: AppSize.s16),
                  Text(
                    'Version 1.0.0',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    '© 2024 Movie App',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.secondaryText,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      onTap: onTap,
      hoverColor: AppColors.primary.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p16,
        vertical: AppPadding.p4,
      ),
    );
  }
}
