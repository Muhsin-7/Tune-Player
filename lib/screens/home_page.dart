import 'dart:core';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';


import '../db/dbfunctions/music_functions.dart';
import '../db/music_model.dart';
import '../utilities/logic.dart';
import '../widgets/appbar.dart';
import '../widgets/song_tile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<HiveSong> _songs = [];
  List<HiveSong> queue = [];
  List<HiveSong> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _fetchSongs();
    _loadSongs();
  }

  void _filterSongs(String query) {
    List<HiveSong> filtered = _songs
        .where((song) =>
            song.title.toLowerCase().contains(query.toLowerCase()) ||
            (song.title.toLowerCase()).contains(query.toLowerCase()))
        .cast<HiveSong>()
        .toList();
    setState(() {
      _filteredSongs = filtered;
    });
  }

  void _resetSearch() {
    setState(() {
      _filteredSongs.clear();
    });
  }

  Future<void> requestPermissions() async {
    int i = 1;
    try {
      // Wait for platform to be ready
      WidgetsFlutterBinding.ensureInitialized();

      // Check for both permissions together
      Map<Permission, PermissionStatus> statuses = await [
        Permission.audio,
        Permission.storage,
      ].request();

      // Check if both permissions are granted
      if (statuses[Permission.audio]!.isGranted &&
          statuses[Permission.storage]!.isGranted) {
        await _fetchSongs();
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      // Handle error appropriately
    }
  }

  void _loadSongs() async {
    // Fetch your songs list here
    List<HiveSong> fetchedSongs =
        await _fetchSongs(); // Your function to load songs
    setState(() {
      _songs = fetchedSongs;
    });
  }

  Future<List<HiveSong>> _fetchSongs() async {
    try {
      List<SongModel> songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      _songs = convertToHiveSongs(songs);
      return convertToHiveSongs(songs); // Convert and return the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching songs: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return []; // Return an empty list if an error occurs
    }
  }

  bool _isFavorite(int songId) {
    var favorites = getAllFavorites();
    return favorites.any((fav) => fav.id == songId);
  }

  void _showMoreOptions(BuildContext context, HiveSong song) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          color: Color.fromARGB(255, 4, 145, 4),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite(song.id) ? Colors.redAccent : Colors.white,
                ),
                title: Text(
                  _isFavorite(song.id)
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    if (_isFavorite(song.id)) {
                      deleteFavorite(song.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${song.title} has been removed from favorites!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      addToFavorites(song.id, song.title, song.data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${song.title} has been added to favorites!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.playlist_add,
                  color: Colors.white,
                ),
                title: Text(
                  'Add to Playlists',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _showPlaylistSelection(context, song);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPlaylistSelection(BuildContext context, HiveSong song) {
    var box = getAllPlaylists();
    List<Playlist> playlists = box;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return playlists.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No playlists available',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      playlists[index].name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      _addSongToPlaylist(context, playlists[index], song);
                      Navigator.pop(context);
                    },
                  );
                },
              );
      },
    );
  }

  void _addSongToPlaylist(
      BuildContext context, Playlist playlist, HiveSong song) {
    addSongsToPlaylist(context, playlist.name, [song]);
  }

  void _showPermissionDeniedPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Denied"),
          content: Text(
              "Storage permission is required to fetch songs. Please allow permission."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text("Allow"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Scaffold(
      appBar: CustomAppBar(
        title: "Tune",
        leading: Icon(Icons.headphones),
        actions: [],
        automaticimply: false,
        centerTitle: true,
        onSearchChanged: _filterSongs,
        onSearchClosed: _resetSearch,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _filteredSongs.isNotEmpty
                    ? ListView.builder(
                        itemCount: _filteredSongs.length,
                        itemBuilder: (context, index) {
                          return SongTile(
                            song: _filteredSongs[index],
                            songs: _filteredSongs,
                            index: index,
                            onMoreOptions: (context, song) {
                              _showMoreOptions(context, song);
                            },
                            onSongTap: (index, hiveSongs0) {},
                          );
                        },
                      )
                    : _songs.isEmpty
                        ? Center(
                            child: Text(
                              "No songs found",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _songs.length,
                            itemBuilder: (context, index) {
                              return SongTile(
                                song: _songs[index],
                                songs: _songs,
                                index: index,
                                onMoreOptions: (context, song) {
                                  _showMoreOptions(context, song);
                                },
                                onSongTap: (index, songs) {
                                  // Update playlist and play the selected song
                                  PlayerController.songsNotifier.value =
                                      List.from(songs);
                                  PlayerController.songsNotifier
                                      .notifyListeners();

                                  // Set the selected song index
                                  PlayerController.currentIndex.value = index;

                                  // Play the selected song
                                  PlayerController.setSong(songs[index]);
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
