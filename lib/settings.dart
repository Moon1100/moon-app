import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/authwrapper.dart';

class SettingsPage1 extends StatelessWidget {
  const SettingsPage1({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Redirect to AuthWrapper which will handle the navigation
    // No need for Navigator.pop or push — AuthWrapper will automatically redirect to AuthPage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You have been logged out")),
    );
    // Optionally, you can navigate to AuthPage directly if needed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              _SingleSection(
                title: "General",
                children: [
                  const _CustomListTile(
                    title: "About Phone",
                    icon: CupertinoIcons.device_phone_portrait,
                  ),
                  _CustomListTile(
                    title: "Dark Mode",
                    icon: CupertinoIcons.moon,
                    trailing: CupertinoSwitch(
                      value: false,
                      onChanged: (value) {},
                    ),
                  ),
                  const _CustomListTile(
                    title: "System Apps Updater",
                    icon: CupertinoIcons.cloud_download,
                  ),
                  const _CustomListTile(
                    title: "Security Status",
                    icon: CupertinoIcons.lock_shield,
                  ),
                ],
              ),
              _SingleSection(
                title: "Network",
                children: [
                  const _CustomListTile(
                    title: "SIM Cards and Networks",
                    icon: Icons.sd_card_outlined,
                  ),
                  _CustomListTile(
                    title: "Wi-Fi",
                    icon: CupertinoIcons.wifi,
                    trailing: CupertinoSwitch(value: true, onChanged: (val) {}),
                  ),
                  _CustomListTile(
                    title: "Bluetooth",
                    icon: CupertinoIcons.bluetooth,
                    trailing: CupertinoSwitch(
                      value: false,
                      onChanged: (val) {},
                    ),
                  ),
                  const _CustomListTile(
                    title: "VPN",
                    icon: CupertinoIcons.desktopcomputer,
                  ),
                ],
              ),
              const _SingleSection(
                title: "Privacy and Security",
                children: [
                  _CustomListTile(
                    title: "Multiple Users",
                    icon: CupertinoIcons.person_2,
                  ),
                  _CustomListTile(
                    title: "Lock Screen",
                    icon: CupertinoIcons.lock,
                  ),
                  _CustomListTile(
                    title: "Display",
                    icon: CupertinoIcons.brightness,
                  ),
                  _CustomListTile(
                    title: "Sound and Vibration",
                    icon: CupertinoIcons.speaker_2,
                  ),
                  _CustomListTile(
                    title: "Themes",
                    icon: CupertinoIcons.paintbrush,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  const _CustomListTile({
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: const Color(0xFF1E1E1E),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      leading: Icon(icon, color: Colors.white),
      trailing: trailing ??
          const Icon(CupertinoIcons.forward, size: 18, color: Colors.grey),
      onTap: () {},
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SingleSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: const Color(0xFF1A1A1A),
          child: Column(children: children),
        ),
      ],
    );
  }
}
