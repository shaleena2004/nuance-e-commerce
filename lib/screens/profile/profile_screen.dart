import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state.dart';
import '../orders/orders_screen.dart';
import '../auth/login_screen.dart';
import '../admin/admin_login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final appState = context.watch<AppStateProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MEMBERSHIP & PROFILE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFC29B38).withValues(alpha: 0.2),
                    backgroundImage: user?.photoUrl.isNotEmpty == true
                        ? NetworkImage(user!.photoUrl)
                        : null,
                    child: user?.photoUrl.isEmpty ?? true
                        ? Text(
                            (user?.displayName.isNotEmpty == true
                                    ? user!.displayName[0]
                                    : 'A')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC29B38),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Valued Customer',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'member@nuance.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onLongPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminLoginScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'TIER NOIR • VIP MEMBER',
                              style: TextStyle(
                                color: Color(0xFFC29B38),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 10),

            // Settings & Preferences
            _buildSectionHeader('PREFERENCES'),
            Material(
              color: theme.cardTheme.color,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          appState.themeMode == ThemeMode.system
                              ? Icons.brightness_auto_rounded
                              : (isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                          color: const Color(0xFFC29B38),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Atelier Theme Appearance',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                appState.themeMode == ThemeMode.system
                                    ? 'Automatic (Following Device System Settings)'
                                    : (appState.themeMode == ThemeMode.dark
                                        ? 'Obsidian Dark Mode'
                                        : 'Alabaster Light Mode'),
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildThemeOption(
                          label: 'Light',
                          icon: Icons.light_mode_outlined,
                          isSelected: appState.themeMode == ThemeMode.light,
                          onTap: () => appState.setThemeMode(ThemeMode.light),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          label: 'Dark',
                          icon: Icons.dark_mode_outlined,
                          isSelected: appState.themeMode == ThemeMode.dark,
                          onTap: () => appState.setThemeMode(ThemeMode.dark),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          label: 'Automatic',
                          icon: Icons.brightness_auto_outlined,
                          isSelected: appState.themeMode == ThemeMode.system,
                          onTap: () => appState.setThemeMode(ThemeMode.system),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Account & Services
            _buildSectionHeader('CUSTOMER ATELIER'),
            Material(
              color: theme.cardTheme.color,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
                ),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Purchase History & Orders',
                    subtitle: 'Track live courier packages and past orders',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrdersScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.pin_drop_outlined,
                    title: 'Shipping Addresses',
                    subtitle: (user?.address.isNotEmpty == true)
                        ? user!.address
                        : 'Tap to add your delivery address',
                    onTap: () => _editAddressDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.phone_outlined,
                    title: 'Courier Contact Number',
                    subtitle: (user?.phoneNumber.isNotEmpty == true)
                        ? user!.phoneNumber
                        : 'Tap to add your courier phone number',
                    onTap: () => _editPhoneDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.support_agent_rounded,
                    title: 'Private Styling Concierge',
                    subtitle: 'Direct WhatsApp & atelier appointment service',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Atelier Concierge is available 24/7 at support@nuance-atelier.com'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign In / Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (authProvider.isAuthenticated) {
                    authProvider.signOut();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                child: Text(
                  authProvider.isAuthenticated ? 'SIGN OUT OF ACCOUNT' : 'SIGN IN / REGISTER',
                  style: TextStyle(
                    color: authProvider.isAuthenticated ? Colors.red.shade400 : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 13, color: isDark ? Colors.white24 : Colors.black26),
                      const SizedBox(width: 4),
                      Text(
                        'Atelier Admin Console',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white24 : Colors.black26,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFFC29B38),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _editAddressDialog(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final controller = TextEditingController(text: user?.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Delivery Address'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Enter complete street address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AuthProvider>().updateProfile(address: controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }

  void _editPhoneDialog(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final controller = TextEditingController(text: user?.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Courier Phone Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'e.g. 0728289118 or +1 (555) 019-2834',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AuthProvider>().updateProfile(phone: controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save Phone'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFC29B38).withValues(alpha: 0.18)
                : (isDark ? const Color(0xFF19191E) : const Color(0xFFF5F5F7)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFFC29B38) : (isDark ? const Color(0xFF282830) : const Color(0xFFE5E5EA)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFFC29B38) : (isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFFC29B38) : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
