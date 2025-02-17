import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tune_player/screens/song_selection.dart';

import '../db/dbfunctions/music_functions.dart';
import '../db/music_model.dart';
import '../utilities/logic.dart';
import '../widgets/appbar.dart';
import '../widgets/colors.dart';


class Playlistspage extends StatefulWidget {
  final Function(String, List<HiveSong>, List<HiveSong>)? onPlaylistTap;
  const Playlistspage({super.key, this.onPlaylistTap});

  @override
  State<Playlistspage> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlistspage> {
  late Box<Playlist> playlistBox;
  String searchQuery = "";
  List<HiveSong> songs = [];
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<HiveSong> _songs = [];

  @override
  void initState() {
    super.initState();
    playlistBox = Hive.box<Playlist>('playlists');
    _fetchSongs();
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

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  void openSongSelectionScreen(Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongSelectionScreen(
          playlist: playlist,
          songss: _songs,
        ),
      ),
    );
  }

  void _showEditPlaylistDialog(BuildContext context, Playlist playlist) {
    TextEditingController nameController =
        TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Playlist Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Enter new playlist name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  editPlaylistName(context, playlist.name, newName);
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

// Function to show the dialog for adding a new playlist
  void showAddPlaylistDialog() {
    TextEditingController playlistNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
             AppColors.primaryColor,
          title: const Text(
            "Create Playlist",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Text color
            ),
          ),
          content: TextField(
            controller: playlistNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Enter Playlist Name",
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                String playlistName = playlistNameController.text.trim();
                if (playlistName.isNotEmpty) {
                  addPlaylist(context, playlistName, []);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.primaryColor,
                      content: const Text(
                        "Playlist name cannot be empty.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void showDeletePlaylistBottomSheet(Playlist playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryColor,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Options",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDeleteConfirmationDialog(playlist);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("Delete Playlist"),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openSongSelectionScreen(playlist);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("Add Songs to Playlist"),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    _showEditPlaylistDialog(context, playlist);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("Edit Name"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmationDialog(Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            "Delete Playlist",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            "Are you sure you want to delete the playlist '${playlist.name}'?",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryColor
              ),
              onPressed: () {
                deletePlaylist(playlist);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await playlistBox.delete(playlist.key);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryColor,
        content: Text(
          "${playlist.name}  Playlist deleted !",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Playlists",
        centerTitle: true,
        automaticimply: true,
        actions: [
          IconButton(
              onPressed: showAddPlaylistDialog, icon: Icon(Icons.playlist_add))
        ],
        onSearchChanged: updateSearchQuery,
        onSearchClosed: () => updateSearchQuery(""),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: playlistBox.listenable(),
          builder: (context, Box<Playlist> box, _) {
            final allPlaylists = box.values.toList();
            final filteredPlaylists = allPlaylists
                .where((playlist) =>
                    playlist.name.toLowerCase().contains(searchQuery))
                .toList();

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two cards per row
                crossAxisSpacing: 16, // Spacing between columns
                mainAxisSpacing: 16, // Spacing between rows
                childAspectRatio: 3 / 3, // Aspect ratio for cards
              ),
              itemCount: filteredPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = filteredPlaylists[index];

                return GestureDetector(
                  onTap: () {
                    if (widget.onPlaylistTap != null) {
    widget.onPlaylistTap!(playlist.name, playlist.songs!, _songs);
  }
                  },
                  child: Card(
                    color: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.library_music,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          height: 1,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                playlist.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDeletePlaylistBottomSheet(playlist);
                                },
                                child: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
