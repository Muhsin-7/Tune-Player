import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/material.dart';

import '../../utilities/logic.dart';
import '../music_model.dart';




// Add a playlist
Future<void> addPlaylist(
    BuildContext context, String name, List<HiveSong> songs) async {
  var box = Hive.box<Playlist>('playlists');
  if (!box.values.any((playlist) => playlist.name == name)) {
    await box.add(Playlist(name: name, songs: songs));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playlist with this name already exists.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

Future<void> deletePlaylist(BuildContext context, String name) async {
  var box = Hive.box<Playlist>('playlists');
  var indexToDelete =
      box.values.toList().indexWhere((playlist) => playlist.name == name);

  if (indexToDelete != -1) {
    await box.deleteAt(indexToDelete);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playlist "$name" deleted successfully.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

Future<void> addSongsToPlaylist(
  BuildContext context,
  String playlistName,
  List<HiveSong> newSongs,
) async {
  var box = Hive.box<Playlist>('playlists');
  var indexToUpdate = box.values
      .toList()
      .indexWhere((playlist) => playlist.name == playlistName);

  if (indexToUpdate != -1) {
    var playlist = box.getAt(indexToUpdate);

    // Filter out songs that are already in the playlist
    var songsToAdd = newSongs.where((newSong) {
      return !playlist!.songs!
          .any((existingSong) => existingSong.id == newSong.id);
    }).toList();

    // If there are songs to add
    if (songsToAdd.isNotEmpty) {
      playlist!.songs!.addAll(songsToAdd);
      await box.putAt(indexToUpdate, playlist);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${songsToAdd.length} song(s) added to playlist "$playlistName" successfully.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'No new songs to add. All songs are already in the playlist.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playlist "$playlistName" not found.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

Future<void> deleteSongsFromPlaylist(
  BuildContext context,
  String playlistName,
  List<SongModel> songsToDelete,
) async {
  var box = Hive.box<Playlist>('playlists');
  var indexToUpdate = box.values
      .toList()
      .indexWhere((playlist) => playlist.name == playlistName);

  if (indexToUpdate != -1) {
    var playlist = box.getAt(indexToUpdate);
    if (playlist != null) {
      playlist.songs!.removeWhere(
          (song) => songsToDelete.any((toDelete) => toDelete.id == song.id));
      await box.putAt(indexToUpdate, playlist);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Songs removed from playlist "$playlistName" successfully.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

Future<void> editPlaylistName(
  BuildContext context,
  String oldName,
  String newName,
) async {
  var box = Hive.box<Playlist>('playlists');

  if (box.values.any((playlist) => playlist.name == newName)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('A playlist with this name already exists.'),
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  // Find the playlist by old name
  var indexToUpdate =
      box.values.toList().indexWhere((playlist) => playlist.name == oldName);

  if (indexToUpdate != -1) {
    var playlist = box.getAt(indexToUpdate);
    if (playlist != null) {
      playlist.name = newName;
      await box.putAt(indexToUpdate, playlist);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist renamed to "$newName" successfully.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playlist "$oldName" not found.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// Get all playlists
List<Playlist> getAllPlaylists() {
  var box = Hive.box<Playlist>('playlists');
  return box.values.toList();
}

// Add a song to favorites
Future<void> addToFavorites(
    int songId, String songTitle, String songData) async {
  var box = Hive.box<Favorite>('favorites');
  await box.add(
      Favorite(id: songId, title: songTitle, data: songData)); // Example artist
}

// Get all favorite songs
List<HiveSong> getAllFavorites() {
  var box = Hive.box<Favorite>('favorites');
  var fv = box.values.toList();
  List<HiveSong> hiveSongsfv = convertFavoritesToHiveSongs(fv);
  return hiveSongsfv;
}

Future<void> deleteFavorite(int songId) async {
  var box = Hive.box<Favorite>('favorites');
  var indexToRemove =
      box.values.toList().indexWhere((favorite) => favorite.id == songId);

  if (indexToRemove != -1) {
    await box.deleteAt(indexToRemove);
    print('Favorite with song ID $songId deleted successfully!');
  }
}

Future<void> addRecentlyPlayed({
  required int id,
  required String title,
  required String data,
  String? artist,
  String? album,
  int? duration,
}) async {
  var box = Hive.box<RecentlyPlayed>('recently_played');
  var existingIndex = box.values.toList().indexWhere((song) => song.id == id);

  if (existingIndex != -1) {
    await box.deleteAt(existingIndex);
  }

  await box.add(RecentlyPlayed(
    id: id,
    title: title,
    data: data,
    artist: artist,
    album: album,
    duration: duration,
  ));

  // Keep only the last 10 recently played songs
  if (box.length > 10) {
    await box.deleteAt(0);
  }
}

List<HiveSong> getRecentlyPlayed() {
  var box = Hive.box<RecentlyPlayed>('recently_played');
  var rc = box.values.toList();
  List<HiveSong> hiveSongsrc = convertrecentlyToHiveSongs(rc);
  return hiveSongsrc;
}

Future<void> removeFromRecentlyPlayed(int songId) async {
  var box = Hive.box<RecentlyPlayed>('recently_played');
  var existingIndex =
      box.values.toList().indexWhere((song) => song.id == songId);

  if (existingIndex != -1) {
    await box.deleteAt(existingIndex);
  }
}

Future<void> addToMostRecentlyPlayed({
  required int id,
  required String title,
  required String data,
  String? artist,
  String? album,
  int? duration,
}) async {
  var box = await Hive.openBox<MostRecentlyPlayed>('most_recently_played');

  // Check if the song already exists in the list
  var existingSongKey = box.keys.firstWhere(
    (key) => box.get(key)!.id == id,
    orElse: () => null,
  );

  if (existingSongKey != null) {
    // If the song exists, update its playCount
    var song = box.get(existingSongKey);
    song!.playCount++;
    await song.save();
  } else {
    // If the song doesn't exist, add it with playCount = 1
    await box.add(MostRecentlyPlayed(
      id: id,
      title: title,
      data: data,
      artist: artist,
      album: album,
      duration: duration,
      playCount: 1, // Set initial playCount to 1
    ));
  }

  if (box.length > 10) {
    await box.deleteAt(0);
  }
}

List<HiveSong> getMostRecentlyPlayed() {
  var box = Hive.box<MostRecentlyPlayed>('most_recently_played');
  var mrc = box.values.where((song) => song.playCount >= 3).toList();
  List<HiveSong> hiveSongsmrc = convertMostplayedToHiveSongs(mrc);
  return hiveSongsmrc;
}

Future<void> removeFromMostPlayed(int songId) async {
  var box = Hive.box<MostRecentlyPlayed>('most_recently_played');
  var existingIndex =
      box.values.toList().indexWhere((song) => song.id == songId);

  if (existingIndex != -1) {
    await box.deleteAt(existingIndex);
  }
}
