import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ProfilePicture extends StatefulWidget {
  final double size;
  final bool ring;

  const ProfilePicture({super.key, this.size = 16, this.ring = true});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  late Future<Uint8List> _avatarFuture;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAvatar();
  }

  void _loadAvatar() {
    _avatarFuture =
        Avatars(Provider.of<Client>(context, listen: false)).getInitials();
  }

  @override
  Widget build(BuildContext context) {
    final double smallerSize =
        widget.ring ? widget.size / 16 * 14 : widget.size;

    return CircleAvatar(
      backgroundColor: Colors.amber,
      radius: widget.size,
      child: CircleAvatar(
        radius: smallerSize,
        child: FutureBuilder<Uint8List>(
          future: _avatarFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircleAvatar(
                radius: smallerSize,
                backgroundColor: Colors.amber,
                child: Icon(
                  Symbols.person_rounded,
                  size: smallerSize,
                  color: Colors.black,
                ),
              );
            } else if (snapshot.hasData) {
              return CircleAvatar(
                radius: smallerSize,
                backgroundImage: MemoryImage(snapshot.data!),
              );
            } else {
              return CircleAvatar(
                radius: smallerSize,
                backgroundColor: Colors.red,
                child: Icon(
                  Symbols.error_rounded,
                  size: smallerSize,
                  color: Colors.white,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
