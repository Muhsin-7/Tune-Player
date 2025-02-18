import 'package:flutter/material.dart';
import 'package:flutter_miniplayer/flutter_miniplayer.dart';
import 'package:hive_flutter/adapters.dart';

import '../db/dbfunctions/music_functions.dart';
import '../db/music_model.dart';
import '../utilities/logic.dart';
import 'artwork.dart';
import 'colors.dart';


const double _playerMinHeight = 70.0;

class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MiniPlayerWidgetState createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  bool _isShuffleMode = false;
  bool _isRepeatMode = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    PlayerController.isPlayingNotifier.addListener(_onPlayingStateChanged);
    _checkFavorite();
  }

  @override
  void dispose() {
    PlayerController.isPlayingNotifier.removeListener(_onPlayingStateChanged);
    super.dispose();
  }

  void _onPlayingStateChanged() {
    setState(() {});
  }

  void _nextSong() {
    PlayerController.nextSong();
    _checkFavorite();
  }

  void _previousSong() {
    PlayerController.previousSong();
    _checkFavorite();
  }

  void _toggleShuffleMode() {
    setState(() {
      _isShuffleMode = !_isShuffleMode;
    });
  }

  void _toggleRepeatMode() {
    setState(() {
      _isRepeatMode = !_isRepeatMode;
    });
  }

  void _toggleFavorite() async {
    final box = Hive.box<Favorite>('favorites');
    final song = PlayerController.currentSong.value;
    if (song == null) return;

    if (isFavorite) {
      final favorite = box.values.firstWhere((fav) => fav.id == song.id);
      await box.delete(favorite.key);
    } else {
      await addToFavorites(song.id, song.title, song.data);
    }
    _checkFavorite();
  }

  void _checkFavorite() {
    final song = PlayerController.currentSong.value;
    if (song == null) return;

    final favorites = getAllFavorites();
    setState(() {
      isFavorite = favorites.any((fav) => fav.id == song.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxPlayerHeight = screenHeight * 0.9; // Adjust this value as needed
    return ValueListenableBuilder<HiveSong?>(
      valueListenable: PlayerController.currentSong,
      builder: (context, song, child) {
        if (song == null) return const SizedBox();

        return Miniplayer(
          minHeight: _playerMinHeight,
          maxHeight: maxPlayerHeight,
          builder: (height, percentage) {
            return Container(
              color: Colors.black,
              child: percentage < 0.2
                  ? _buildMiniPlayer(song)
                  : _buildFullPlayer(song),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniPlayer(HiveSong song) {
    return Container(
      color: AppColors.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: _playerMinHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.music_note, color: Colors.white),
          Expanded(
            child: Text(
              '${song.title} - ${song.artist ?? "Unknown Artist"}',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: PlayerController.isPlayingNotifier,
              builder: (context, isPlaying, _) {
                return Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white);
              },
            ),
            onPressed: PlayerController.togglePlayPause,
          ),
        ],
      ),
    );
  }

  Widget _buildFullPlayer(HiveSong song) {
    return SingleChildScrollView(
      child: ColoredBox(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 90),
            ArtworkWidget(id: song.id),
            const SizedBox(height: 60),
            Text(
              song.title.length > 22
                  ? '${song.title.substring(0, 22)}...'
                  : song.title,
              style: const TextStyle(fontSize: 30, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<Duration>(
              valueListenable: PlayerController.positionNotifier,
              builder: (context, position, _) {
                final currentTime = _formatDuration(position);
                 final totalTime = _formatDuration(PlayerController.durationNotifier.value);
                return Column(
                  children: [
                     Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentTime,
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(width: 250), 
                      Text(
                        totalTime,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                    Slider(
                      value: position.inSeconds.toDouble().clamp(
                          0,
                          PlayerController.durationNotifier.value.inSeconds
                              .toDouble()),
                      min: 0,
                      max: PlayerController.durationNotifier.value.inSeconds
                          .toDouble(),
                      onChanged: (value) =>
                          PlayerController.seekTo(Duration(seconds: value.toInt())),
                      activeColor: AppColors.primaryColor,
                      inactiveColor: Colors.grey,
                    ),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous,
                      color: AppColors.primaryColor),
                  iconSize: 40,
                  onPressed: _previousSong,
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10,
                      color: AppColors.primaryColor),
                  onPressed: () => PlayerController.skipBackward(10),
                ),
                IconButton(
                  icon: ValueListenableBuilder<bool>(
                    valueListenable: PlayerController.isPlayingNotifier,
                    builder: (context, isPlaying, _) {
                      return Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppColors.primaryColor, size: 50);
                    },
                  ),
                  onPressed: PlayerController.togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10,
                      color: AppColors.primaryColor),
                  onPressed: () => PlayerController.skipForward(10),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next,
                      color: AppColors.primaryColor),
                  iconSize: 40,
                  onPressed: _nextSong,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _toggleShuffleMode,
                  icon: Icon(Icons.shuffle,
                      color: _isShuffleMode
                          ? AppColors.primaryColor
                          : Colors.grey),
                ),
                IconButton(
                  icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.primaryColor : null),
                  onPressed: _toggleFavorite,
                ),
                IconButton(
                  onPressed: _toggleRepeatMode,
                  icon: Icon(Icons.repeat,
                      color:
                          _isRepeatMode ? AppColors.primaryColor : Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}
