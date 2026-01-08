import 'package:flutter/material.dart';
import 'main.dart';

const Color kPrimaryGreen = Color(0xFF0A6847);
const Color kScaffoldBackground = Color(0xFFF5F7F9);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifEnabled = true;
  bool _newsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final Color cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Pengaturan",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildSectionHeader("Notifikasi & Preferensi", textColor),
            _buildCardContainer(
              context,
              cardColor: cardColor,
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  title: "Aktifkan Notifikasi",
                  value: _notifEnabled,
                  textColor: textColor,
                  onChanged: (val) => setState(() => _notifEnabled = val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.newspaper_outlined,
                  title: "Peringatan Berita",
                  value: _newsEnabled,
                  textColor: textColor,
                  onChanged: (val) => setState(() => _newsEnabled = val),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Keamanan & Akun", textColor),
            _buildCardContainer(
              context,
              cardColor: cardColor,
              children: [
                _buildNavTile(
                  icon: Icons.security_outlined,
                  title: "Keamanan Akun",
                  textColor: textColor,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildNavTile(
                  icon: Icons.credit_card_outlined,
                  title: "Kelola Pembayaran",
                  textColor: textColor,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Tampilan & Bahasa", textColor),
            _buildCardContainer(
              context,
              cardColor: cardColor,
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text("Pilih Bahasa",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPrimaryGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("Indonesia", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                _buildDivider(),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: Text("Mode Gelap",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                  trailing: Switch(
                    value: MyApp.themeNotifier.value == ThemeMode.dark,
                    activeColor: Colors.white,
                    activeTrackColor: kPrimaryGreen,
                    onChanged: (val) {
                      MyApp.themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Tindakan Akun", textColor),
            _buildCardContainer(
              context,
              cardColor: cardColor,
              children: [
                ListTile(
                  leading: Icon(Icons.logout, color: textColor),
                  title: Text("Keluar",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                  },
                ),
                _buildDivider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text("Hapus Akun",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer(
    BuildContext context, {
    required List<Widget> children,
    required Color cardColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
      trailing: Switch(
        value: value,
        activeColor: Colors.white,
        activeTrackColor: kPrimaryGreen,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}