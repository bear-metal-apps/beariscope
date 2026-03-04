import 'package:beariscope/models/drive_team_note.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/permissions_provider.dart';

final myDriveTeamNotesProvider =
    FutureProvider.family<Map<int, DriveTeamNote>, String>((
      ref,
      matchKey,
    ) async {
      final allDocs = await ref.watch(scoutingDataProvider.future);
      final authMe = await ref.watch(authMeProvider.future);
      final userId = authMe?.user.id ?? '';

      if (userId.isEmpty) return {};

      final notes = <int, DriveTeamNote>{};
      for (final doc in allDocs) {
        final meta = doc.meta;
        if (meta == null) continue;
        if (meta['type']?.toString() != 'drive_team') continue;
        if (meta['matchKey']?.toString() != matchKey) continue;
        if (meta['userId']?.toString() != userId) continue;

        final note = DriveTeamNote.fromScoutingDocument(doc);
        notes[note.teamNumber] = note;
      }

      return notes;
    });
