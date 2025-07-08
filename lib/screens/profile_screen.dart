import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_auth_provider.dart';
import '../widgets/splash_screen.dart';
import '../models/user_model.dart';
import '../models/collectible_model.dart';
import '../models/mission_model.dart';
import '../models/distribution_model.dart';
import '../helpers/localization_helper.dart';
import './subscreens/missions/award_screen.dart';
import './subscreens/profile/language_page.dart';
import './subscreens/profile/account_settings_screen.dart';
import '../widgets/profile_pic_changer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shadow_circle.dart';
import '../widgets/profile/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<UserModel>();
    final currentUser = userModel.currentUser;
    final userPic = currentUser?['profileImg'];
    final username = currentUser?['username'] ??
        translate("profile_screen_build_default_user", context);

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
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                shadowCircle(userPic ?? 'assets/images/kloppocarIcon.png', 32.0,
                    userPic != null),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    username,
                    style: GoogleFonts.chakraPetch(
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 30, thickness: 1, indent: 16, endIndent: 16),
          ProfileMenuItem(
            icon: Icons.manage_accounts_outlined,
            title: translate("profile_account_settings", context),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AccountSettingsScreen(),
              ));
            },
          ),
          ProfileMenuItem(
            icon: Icons.image_outlined,
            title: translate("profile_screen_build_change_pic", context),
            onTap: () => showProfilePicModal(context),
          ),
          ProfileMenuItem(
            icon: Icons.emoji_events_outlined,
            title: translate("profile_awards", context),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AwardScreen()),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.language_outlined,
            title: translate('profile_language_label', context),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LanguagePage()),
              );
            },
          ),
          const SizedBox(height: 20),
          ProfileMenuItem(
              icon: Icons.logout,
              title: translate("profile_signout_label", context),
              color: Colors.red,
              onTap: () async {
                context.read<CollectibleModel>().clearData();
                context.read<MissionModel>().clearData();
                context
                    .read<DistributionModel>()
                    .clearData(); // Assuming you add a clearData method here too
                context
                    .read<UserModel>()
                    .clearUser(); // Assuming you add a clearData method here too
                await context.read<AppAuthProvider>().signOut();

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const SplashScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              }),
        ],
      ),
    );
  }
}
