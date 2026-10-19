import 'package:flutter/material.dart';
import '../providers/app_state.dart';

class AtelierThemeModeSelector extends StatelessWidget {
  final AppStateProvider appState;
  final bool isDark;

  const AtelierThemeModeSelector({
    super.key,
    required this.appState,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      tooltip: 'Theme Appearance',
      offset: const Offset(0, 48),
      icon: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF232328) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFC29B38).withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Icon(
          appState.themeMode == ThemeMode.system
              ? Icons.brightness_auto_rounded
              : (isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
          color: const Color(0xFFC29B38),
          size: 19,
        ),
      ),
      color: isDark ? const Color(0xFF1A1A20) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C2C35) : const Color(0xFFE5E5EA),
        ),
      ),
      onSelected: (mode) => appState.setThemeMode(mode),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(
                Icons.light_mode_rounded,
                size: 18,
                color: appState.themeMode == ThemeMode.light
                    ? const Color(0xFFC29B38)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Light Mode (Alabaster atelier styling)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: appState.themeMode == ThemeMode.light
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: appState.themeMode == ThemeMode.light
                            ? const Color(0xFFC29B38)
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const Text(
                      'Crisp daylight luxury aesthetics',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (appState.themeMode == ThemeMode.light)
                const Icon(Icons.check_rounded, size: 16, color: Color(0xFFC29B38)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(
                Icons.dark_mode_rounded,
                size: 18,
                color: appState.themeMode == ThemeMode.dark
                    ? const Color(0xFFC29B38)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Dark Mode (Obsidian luxury styling)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: appState.themeMode == ThemeMode.dark
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: appState.themeMode == ThemeMode.dark
                            ? const Color(0xFFC29B38)
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const Text(
                      'Obsidian noir atelier dark aesthetics',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (appState.themeMode == ThemeMode.dark)
                const Icon(Icons.check_rounded, size: 16, color: Color(0xFFC29B38)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.brightness_auto_rounded,
                size: 18,
                color: appState.themeMode == ThemeMode.system
                    ? const Color(0xFFC29B38)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Automatic (Follows system / OS brightness)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: appState.themeMode == ThemeMode.system
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: appState.themeMode == ThemeMode.system
                            ? const Color(0xFFC29B38)
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const Text(
                      'Adaptive system appearance',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (appState.themeMode == ThemeMode.system)
                const Icon(Icons.check_rounded, size: 16, color: Color(0xFFC29B38)),
            ],
          ),
        ),
      ],
    );
  }
}
