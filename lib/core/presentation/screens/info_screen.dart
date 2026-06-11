import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Info',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Watch New Movie Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE8B84B).withOpacity(0.2),
                    const Color(0xFFC084FC).withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE8B84B).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.movie_outlined,
                    size: 64,
                    color: const Color(0xFFE8B84B),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Watch New Movie',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover latest movies and shows',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: const Color(0xFF8892AA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to language selection screen
                      context.go('/language-selection');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8B84B),
                      foregroundColor: const Color(0xFF090C14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Browse Movies',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Rate Us Section
            _buildActionTile(
              icon: Icons.star_outline,
              title: 'Rate Us',
              subtitle: 'Help us improve with your feedback',
              color: const Color(0xFFC084FC),
              onTap: () {
                // Replace with your app's store URL
                _launchURL('https://play.google.com/store/apps');
              },
            ),

            const SizedBox(height: 16),

            // Share Section
            _buildActionTile(
              icon: Icons.share_outlined,
              title: 'Share',
              subtitle: 'Share this app with your friends',
              color: const Color(0xFF6366F1),
              onTap: () {
                // Replace with your app's share URL
                _launchURL('https://play.google.com/store/apps');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1422),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF8892AA),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
