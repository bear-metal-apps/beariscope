import 'package:flutter/material.dart';

/// A list/column of cards with consistent spacing and max-width constraint
class BeariscopeCardList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;
  final double spacing;

  const BeariscopeCardList({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.maxWidth = 600,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      padding: padding,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: children[index],
          ),
        );
      },
    );
  }
}

/// A card component with title, optional subtitle, optional trailing widget, and optional onTap
class BeariscopeCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const BeariscopeCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding!,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
