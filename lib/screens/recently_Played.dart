import 'package:flutter/material.dart';

import '../db/dbfunctions/music_functions.dart';
import '../db/music_model.dart';
import '../utilities/logic.dart';
import '../widgets/appbar.dart';
import '../widgets/song_tile.dart';


class Recentlyplayed extends StatefulWidget {
  const Recentlyplayed({super.key});

  @override
  State<Recentlyplayed> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Recentlyplayed> {
  List<HiveSong> _allSongs = [];
  List<HiveSong> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _recenltyplayed();
  }

  void _recenltyplayed() async {
    var recentlyplayed = getRecentlyPlayed();
    setState(() {
      _allSongs = recentlyplayed;
      _filteredSongs = recentlyplayed;
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
      _filteredSongs = _allSongs; 
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
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Remove from Recently Played"),
              onTap: () {
                setState(() {
                  _allSongs.remove(song);
                  _filteredSongs.remove(song);
                });
                removeFromRecentlyPlayed(song.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Removed ${song.title} from Recently Played"),
                  ),
                );
              },
            ),
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
                leading: Icon(
                  _isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite(song.id) ? Colors.redAccent : const Color.fromARGB(255, 255, 0, 0),
                ),
                title: Text(
                  _isFavorite(song.id)
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
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
          ],
        ),
      );
    },
  );
}
  bool _isFavorite(int songId) {
    var favorites = getAllFavorites();
    return favorites.any((fav) => fav.id == songId);
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Recently Played",
        automaticimply: true,
        onSearchChanged: _filterSongs,
        onSearchClosed: _resetSearch,
      ),
      body: _filteredSongs.isEmpty
          ? Center(child: Text("No songs"))
          : ListView.builder(
              itemCount: _filteredSongs.length,
              itemBuilder: (context, index) {
                final song = _filteredSongs[index];
                return SongTile(
                                    song: _filteredSongs[index],
                                    songs: _filteredSongs,
                                    index: index,
                                    onMoreOptions: (context, song) {
                                      _showSongOptions(context,song );
                                    },
                                    onSongTap: (index, songs) {
                                      // Update playlist and play the selected song
                                      PlayerController.songsNotifier.value =
                                          List.from(songs);
                                      PlayerController.songsNotifier
                                          .notifyListeners();

                                      // Set the selected song index
                                      PlayerController.currentIndex.value =
                                          index;

                                      // Play the selected song
                                      PlayerController.setSong(songs[index]);
                                    });

              },
            ),
    );
  }
}
