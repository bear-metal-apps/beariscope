import 'package:beariscope/components/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>(
  (ref) => AccentColorNotifier(),
);

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(Colors.lightBlue) {
    _loadColor();
  }

  Future<void> _loadColor() async {
    final preferences = await SharedPreferences.getInstance();
    final savedColor = preferences.getInt('accentColor');
    if (savedColor != null) {
      state = Color(savedColor);
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', color.toARGB32());
  }
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('themeMode');

    if (savedMode != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
  }
}

final accentColors = [
  Colors.pink,
  Colors.red,
  Colors.orange,
  Colors.amber,
  Colors.lightGreenAccent,
  Colors.green,
  Colors.teal,
  Colors.cyanAccent,
  Colors.lightBlue,
  Colors.purpleAccent,
  Colors.deepPurple,
];

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedColor = ref.watch(accentColorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SettingsGroup(
            title: 'Interface',
            children: [
              ListTile(
                leading: const Icon(Symbols.dark_mode_rounded),
                title: const Text('Theme Mode'),
                contentPadding: EdgeInsets.all(16),
                trailing: DropdownMenu<ThemeMode>(
                  // width: 140,
                  initialSelection: themeMode,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(),
                  ),
                  onSelected: (ThemeMode? newMode) {
                    if (newMode != null) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(newMode);
                    }
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: ThemeMode.system, label: 'System'),
                    DropdownMenuEntry(value: ThemeMode.light, label: 'Light'),
                    DropdownMenuEntry(value: ThemeMode.dark, label: 'Dark'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Personalization Group
          SettingsGroup(
            title: 'Accent Color',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: accentColors.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 48,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final color = accentColors[index];
                    final isSelected =
                        color.toARGB32() == selectedColor.toARGB32();

                    return GestureDetector(
                      onTap: () {
                        ref.read(accentColorProvider.notifier).setColor(color);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border:
                              isSelected
                                  ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check_rounded,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                )
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
