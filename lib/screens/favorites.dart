import 'package:flutter/material.dart';

import '../db/dbfunctions/music_functions.dart';
import '../db/music_model.dart';
import '../utilities/logic.dart';
import '../widgets/appbar.dart';
import '../widgets/song_tile.dart';


class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  List<HiveSong> _allSongs = []; // All favorite songs
  List<HiveSong> _filteredSongs = []; // Songs filtered by search
  final bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    var favorites = getAllFavorites();
    setState(() {
      _allSongs = favorites;
      _filteredSongs = favorites;
    });
  }

  void _filterSongs(String query) {
    List<HiveSong> filtered = _allSongs
        .where((song) =>
            song.title.toLowerCase().contains(query.toLowerCase()) ||
            (song.title.toLowerCase()).contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredSongs = filtered;
    });
  }

  void _resetSearch() {
    setState(() {
      _filteredSongs = _allSongs; // Reset to all songs.
    });
  }

  void _showSongOptions(BuildContext context, HiveSong song) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.blue),
                title: const Text("Add to Playlist"),
                onTap: () {
                  Navigator.pop(context);
                  _showPlaylistSelection(
                    context,
                    HiveSong(
                      id: song.id,
                      title: song.title,
                      data: song.data,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text("Remove from Favorites"),
                onTap: () {
                  deleteFavorite(song.id);
                  _loadFavorites();
                  Navigator.pop(context);
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
      backgroundColor: const Color.fromARGB(221, 255, 255, 255),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return playlists.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No playlists available',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              )
            : ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      playlists[index].name,
                      style:
                          const TextStyle(color: Color.fromARGB(255, 11, 0, 0)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Favorites",
        automaticimply: true,
        onSearchChanged: _filterSongs,
        onSearchClosed: _resetSearch,
      ),
      body: _filteredSongs.isEmpty
          ? Center(child: Text("No Favorites"))
          : ListView.builder(
              itemCount: _filteredSongs.length,
              itemBuilder: (context, index) {
                final song = _filteredSongs[index];

                return SongTile(
                    song: _filteredSongs[index],
                    songs: _filteredSongs,
                    index: index,
                    onMoreOptions: (context, song) {
                      _showSongOptions(context, song);
                    },
                    onSongTap: (index, songs) {
                      // Update playlist and play the selected song
                      PlayerController.songsNotifier.value = List.from(songs);
                      PlayerController.songsNotifier.notifyListeners();

                      // Set the selected song index
                      PlayerController.currentIndex.value = index;

                      // Play the selected song
                      PlayerController.setSong(songs[index]);
                    });
              },
            ),
    );
  }
}
