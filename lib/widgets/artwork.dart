import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'colors.dart';


class ArtworkWidget extends StatelessWidget {
  final int id;

  const ArtworkWidget({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 160,
      backgroundColor: Colors.grey[300],
      child: ClipOval(
        child: SizedBox(
          width: 320,
          height: 320,
          child: QueryArtworkWidget(
            id: id,
            type: ArtworkType.AUDIO,
            artworkFit: BoxFit.cover,
            nullArtworkWidget: Container(
              color: AppColors.primaryColor,
              child: const Icon(
                Icons.music_note,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
