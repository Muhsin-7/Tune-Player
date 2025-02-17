import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tune_player/db/music_model.dart';


import '../db/dbfunctions/music_functions.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String currentTitle = 'Unknown Song';

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Future<void> play(String url, int id, {String title = 'Unknown Song'}) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: id.toString(),
            album: "My Music",
            title: title,
            artUri: Uri.parse("https://example.com/album_art.jpg"), // Change this to real album art URL
          ),
        ),
      );
      await _audioPlayer.play();
      isPlaying = true;
      currentTitle = title;
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      isPlaying = false;
    } else {
      await _audioPlayer.play();
      isPlaying = true;
    }
  }

  Future<void> seekTo(int seconds) async {
    await _audioPlayer.seek(Duration(seconds: seconds));
  }

  Future<void> skipForward(int seconds) async {
    await _audioPlayer.seek(_audioPlayer.position + Duration(seconds: seconds));
  }

  Future<void> skipBackward(int seconds) async {
    final newPosition =
        (_audioPlayer.position - Duration(seconds: seconds)).inSeconds;
    await _audioPlayer
        .seek(Duration(seconds: newPosition < 0 ? 0 : newPosition));
  }

  String get currentSongTitle => currentTitle;

  void dispose() {
    _audioPlayer.dispose();
  }
}


class PlayerController {
  static final AudioManager _audioManager =
      AudioManager(); // AudioManager Instance

  static final ValueNotifier<List<HiveSong>> songsNotifier =
      ValueNotifier([]); // Song List
  static final ValueNotifier<int> currentIndex =
      ValueNotifier(0); // Track Current Index
  static final ValueNotifier<HiveSong?> currentSong = ValueNotifier(null);
  static final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  static final ValueNotifier<Duration> positionNotifier =
      ValueNotifier(Duration.zero);
  static final ValueNotifier<Duration> durationNotifier =
      ValueNotifier(Duration.zero);

  static Stream<PlayerState> get playerStateStream =>
      _audioManager.playerStateStream;

  /// **Set Playlist and Start Playing**
  static void setPlaylist(List<HiveSong> playlist, {int startIndex = 0}) {
    songsNotifier.value = playlist;
    currentIndex.value = startIndex;
    setSong(playlist[startIndex]);
  }

  /// **Set and Play Song**
  static void setSong(HiveSong song) async {
    currentSong.value = song;
    isPlayingNotifier.value = true;
    await addRecentlyPlayed(id: song.id, title: song.title, data: song.data);
    await addToMostRecentlyPlayed(
        id: song.id, title: song.title, data: song.data);

    // Play song using AudioManager
    await _audioManager.play(song.data, song.id, title: song.title);

    // Listen for playback updates
    _audioManager.positionStream.listen((position) {
      positionNotifier.value = position;
    });

    _audioManager.durationStream.listen((duration) {
      if (duration != null) {
        durationNotifier.value = duration;        
      }
    });

    _audioManager.playerStateStream.listen((state) {
      isPlayingNotifier.value = state.playing;

      // Handle auto-play next song
      if (state.processingState == ProcessingState.completed) {
        nextSong();
      }
    });
  }

  /// **Skip to Next Song**
  static void nextSong() {
    if (currentIndex.value < songsNotifier.value.length - 1) {
      currentIndex.value++;
      setSong(songsNotifier.value[currentIndex.value]);
    } else {
      // Loop back to the first song
      currentIndex.value = 0;
      setSong(songsNotifier.value[currentIndex.value]);
    }
  }

  /// **Skip to Previous Song**
  static void previousSong() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      setSong(songsNotifier.value[currentIndex.value]);
    } else {
      // Loop back to the last song
      currentIndex.value = songsNotifier.value.length - 1;
      setSong(songsNotifier.value[currentIndex.value]);
    }
  }

  /// **Toggle Play/Pause**
  static Future<void> togglePlayPause() async {
    await _audioManager.togglePlayPause();
    isPlayingNotifier.value = _audioManager.isPlaying;
  }

  /// **Seek to Position**
  static Future<void> seekTo(Duration position) async {
    await _audioManager.seekTo(position.inSeconds);
  }

  /// **Skip Forward**
  static Future<void> skipForward(int seconds) async {
    await _audioManager.skipForward(seconds);
  }

  /// **Skip Backward**
  static Future<void> skipBackward(int seconds) async {
    await _audioManager.skipBackward(seconds);
  }
}


//converting Favorite model to Hivesong model ..
List<HiveSong> convertFavoritesToHiveSongs(List<Favorite> favorites) {
  return favorites.map((favorite) {
    return HiveSong(
      id: favorite.id,
      title: favorite.title,
      data: favorite.data,
      artist: favorite.artist,
      album: favorite.album,
      duration: favorite.duration,
    );
  }).toList();
}

List<HiveSong> convertToHiveSongs(List<SongModel> songs) {
  return songs.map((song) {
    return HiveSong(
      id: song.id,
      title: song.title,
      data: song.data,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
    );
  }).toList();
}

List<HiveSong> convertrecentlyToHiveSongs(List<RecentlyPlayed> recently) {
  return recently.map((favorite) {
    return HiveSong(
      id: favorite.id,
      title: favorite.title,
      data: favorite.data,
      artist: favorite.artist,
      album: favorite.album,
      duration: favorite.duration,
    );
  }).toList();
}

List<HiveSong> convertMostplayedToHiveSongs(List<MostRecentlyPlayed> recently) {
  return recently.map((favorite) {
    return HiveSong(
      id: favorite.id,
      title: favorite.title,
      data: favorite.data,
      artist: favorite.artist,
      album: favorite.album,
      duration: favorite.duration,
    );
  }).toList();
}
