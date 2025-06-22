import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/app_auth_provider.dart';
import '../widgets/splash_screen.dart';
import '../models/locale_provider.dart';
import '../helpers/localization_helper.dart';
import './subscreens/missions/award_screen.dart';
import './subscreens/profile/account_settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // A custom widget for the styled list items
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: Colors.grey[400], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Uri ppUrl = Uri.parse('https://deins.io/data-privacy');

    Future<void> _launchUrl(url) async {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC), // A modern, slightly off-white background
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        title: Text(
          translate("profile_header", context),
          style: const TextStyle(
            fontSize: 28,
            color: Colors.black,
            fontFamily: 'ChakraPetch',
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: <Widget>[
          _buildProfileMenuItem(
            icon: Icons.manage_accounts_outlined,
            title: translate("profile_account_settings", context),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AccountSettingsScreen(),
              ));
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.emoji_events_outlined,
            title: translate("profile_awards", context),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AwardScreen()),
              );
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.gavel_outlined,
            title: translate("profile_pp_label", context),
            onTap: () => _launchUrl(ppUrl),
          ),
          _buildProfileMenuItem(
            icon: Icons.language_outlined,
            title: translate('profile_language_label', context),
            onTap: () {
              Provider.of<LocaleProvider>(context, listen: false)
                  .toggleLocale();
            },
          ),
          const SizedBox(height: 20),
          _buildProfileMenuItem(
            icon: Icons.logout,
            title: translate("profile_signout_label", context),
            color: Colors.red,
            onTap: () async {
              await Provider.of<AppAuthProvider>(context, listen: false)
                  .signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
