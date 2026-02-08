import 'package:beariscope/components/beariscope_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class UpNextMatchCard extends StatelessWidget {
  final String displayName;
  final String matchKey;
  final String time;

  const UpNextMatchCard({
    super.key,
    required this.displayName,
    required this.matchKey,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return BeariscopeCard(
      title: displayName,
      subtitle: time,
      onTap: () => context.push('/up_next/$matchKey'),
    );
  }
}

class UpNextEventCard extends StatelessWidget {
  final String eventKey;
  final String name;
  final String dateLabel;

  const UpNextEventCard({
    super.key,
    required this.eventKey,
    required this.name,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return BeariscopeCard(
      title: name,
      subtitle: dateLabel,
      trailing: Icon(
        Icons.open_in_new,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: () async {
        final uri = Uri.parse('https://www.thebluealliance.com/event/$eventKey');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open TBA')),
            );
          }
        }
      },
    );
  }
}