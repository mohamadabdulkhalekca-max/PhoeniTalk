import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uniapp/features/auth/data/services/auth_service.dart';
import 'package:uniapp/features/auth/views/login_view.dart';
import 'package:uniapp/features/settings/views/contact_support_view.dart';
import 'package:uniapp/features/settings/views/privacy_policy_view.dart';
import 'package:uniapp/features/settings/views/terms_and_conditions_view.dart';

class SettingsViewBody extends StatelessWidget {
  const SettingsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const SettingsTileList(),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTileList extends StatelessWidget {
  const SettingsTileList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsTile(
          icon: Icons.support_agent,
          title: 'Contact Support',
          showDivider: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ContactSupportView(),
              ),
            );
          },
        ),
        SettingsTile(
          icon: Icons.article_outlined,
          title: 'Terms & Conditions',
          showDivider: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TermsAndConditionsView(),
              ),
            );
          },
        ),
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          showDivider: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyView(),
              ),
            );
          },
        ),
        SettingsTile(
          icon: Icons.logout,
          title: 'Logout',
          isRed: true,
          onTap: () {
            AuthService.instance.logout();
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => const LoginView()),
              (routes) => false,
            );
          },
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showDivider;
  final bool isRed;
  final void Function()? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.showDivider = false,
    this.isRed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isRed ? Colors.red : Colors.red[800]),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isRed ? Colors.red : Colors.black87,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
          ),
      ],
    );
  }
}
