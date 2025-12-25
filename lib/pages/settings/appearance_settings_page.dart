import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier());
final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>((ref) => AccentColorNotifier());

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
    await prefs.setInt('accentColor', color.value);
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  onChanged: (newMode) {
                    if (newMode != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(newMode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Accent Color'),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: accentColors.length,
                      gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 40,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final color = accentColors[index];
                        final isSelected = color == selectedColor;

                        return GestureDetector(
                          onTap: () {
                            ref.read(accentColorProvider.notifier).setColor(color);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              border: isSelected
                                  ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 1,
                              )
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




