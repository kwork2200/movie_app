import 'package:flutter/material.dart';
import '../../resources/app_colors.dart';
import '../../resources/app_values.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppPadding.p20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSize.s20),
                ),
                child: const Icon(
                  Icons.privacy_tip_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSize.s24),

            // Last Updated
            Center(
              child: Text(
                'Last Updated: January 2024',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: AppSize.s32),

            // Introduction
            _PolicySection(
              title: 'Introduction',
              content:
                  'Welcome to Movie App. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our app and tell you about your privacy rights.',
              textTheme: textTheme,
            ),

            // Information We Collect
            _PolicySection(
              title: 'Information We Collect',
              content:
                  'We may collect, use, store and transfer different kinds of personal data about you, including:',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Identity Data: username, profile information',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Usage Data: information about how you use our app',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Technical Data: device information, IP address, browser type',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Preferences: your watchlist, favorites, and settings',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // How We Use Your Information
            _PolicySection(
              title: 'How We Use Your Information',
              content: 'We use your information to:',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Provide and maintain our service',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Improve user experience and app functionality',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Personalize content and recommendations',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Communicate with you about updates and features',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // Data Security
            _PolicySection(
              title: 'Data Security',
              content:
                  'We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorized way. We limit access to your personal data to those who have a genuine business need to know it.',
              textTheme: textTheme,
            ),

            // Third-Party Services
            _PolicySection(
              title: 'Third-Party Services',
              content:
                  'We use third-party services to provide better functionality:',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'The Movie Database (TMDB) API for movie information',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Firebase for authentication and data storage',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Google AdMob for displaying advertisements',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // Your Rights
            _PolicySection(
              title: 'Your Rights',
              content: 'You have the right to:',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Access your personal data',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Request correction of your personal data',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Request deletion of your personal data',
              textTheme: textTheme,
            ),
            _BulletPoint(
              text: 'Object to processing of your personal data',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s16),

            // Children's Privacy
            _PolicySection(
              title: "Children's Privacy",
              content:
                  'Our service is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
              textTheme: textTheme,
            ),

            // Changes to This Policy
            _PolicySection(
              title: 'Changes to This Privacy Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
              textTheme: textTheme,
            ),

            // Contact Us
            _PolicySection(
              title: 'Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at:',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSize.s8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppPadding.p16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSize.s12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'support@movieapp.com',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSize.s32),

            // Footer
            Center(
              child: Text(
                '© 2024 Movie App. All Rights Reserved.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: AppSize.s24),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  final TextTheme textTheme;

  const _PolicySection({
    required this.title,
    required this.content,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSize.s12),
        Text(
          content,
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSize.s24),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final TextTheme textTheme;

  const _BulletPoint({
    required this.text,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppPadding.p16,
        bottom: AppPadding.p8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSize.s12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
