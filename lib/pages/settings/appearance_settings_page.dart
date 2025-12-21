import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final accentColorProvider = StateProvider<Color>((ref) => Colors.lightBlue);
final accentColors = [
  Colors.lightBlue,
  Colors.deepPurple,
  Colors.green,
  Colors.teal,
  Colors.orange,
  Colors.red,
  Colors.pink,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  onChanged: (newMode) {
                    if (newMode != null) {
                      ref.read(themeModeProvider.notifier).state = newMode;
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding:const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accent Color'
                    ),

                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
                            ref.read(accentColorProvider.notifier).state = color;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.rectangle,
                              border: isSelected ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 1,
                              ): null,
                            ),
                            child: isSelected ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            ): null,
                          )
                        );
                      }
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



