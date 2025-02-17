import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';


import '../db/music_model.dart';
import 'colors.dart';

class SongTile extends StatelessWidget {
  final HiveSong song;
  final List<HiveSong> songs;
  final int index;
  final Function(BuildContext, HiveSong) onMoreOptions;
  final Function(int index, List<HiveSong> songs) onSongTap;

  const SongTile(
      {super.key,
      required this.song,
      required this.songs,
      required this.index,
      required this.onMoreOptions,
      required this.onSongTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: QueryArtworkWidget(
        id: song.id,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        nullArtworkWidget: const CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          radius: 23,
          child: Icon(Icons.music_note, color: Colors.white),
        ),
      ),
      title: Text(
        song.title.length > 25
            ? '${song.title.substring(0, 25)}...'
            : song.title,
      ),
      subtitle: Text(
        song.artist ?? "Unknown Artist",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => onMoreOptions(context, song),
      ),
      onTap: () {
        onSongTap(index,songs);
      },
    );
  }
}
