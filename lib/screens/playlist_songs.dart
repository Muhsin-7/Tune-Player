import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tune_player/screens/song_selection.dart';

import '../db/music_model.dart';
import '../utilities/logic.dart';
import '../widgets/colors.dart';
import '../widgets/song_tile.dart';


class PlaylistSongs extends StatefulWidget {
  final String playlistName;
  final List<HiveSong> songs;
  final List<HiveSong> allsongs;
  final VoidCallback? onBack;

  const PlaylistSongs(
      {super.key,
      required this.playlistName,
      required this.songs,
      required this.allsongs,
      this.onBack});

  @override
  State<PlaylistSongs> createState() => _PlaylistSongsState();
}

class _PlaylistSongsState extends State<PlaylistSongs> {
  late Box<Playlist> playlistBox;
  late String playlistname;

  @override
  void initState() {
    super.initState();
    playlistBox = Hive.box<Playlist>('playlists');
    playlistname = widget.playlistName;
  }

  Playlist? getCurrentPlaylist() {
    try {
      return playlistBox.values.firstWhere(
        (playlist) => playlist.name == widget.playlistName,
      );
    } catch (e) {
      return null;
    }
  }

  /// Show bottom sheet with playlist options.
  void _showPlaylistOptions() {
    final playlist = getCurrentPlaylist();
    if (playlist == null) return;

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
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text("Edit Name"),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPlaylistDialog(playlist);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Playlist"),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(playlist);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.blue),
                title: const Text("Add Songs to Playlist"),
                onTap: () {
                  Navigator.pop(context);
                  _openSongSelectionScreen(playlist);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show dialog to edit the playlist name.
  void _showEditPlaylistDialog(Playlist playlist) {
    TextEditingController nameController =
        TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          title: const Text(
            "Edit Playlist Name",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter new playlist name",
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  // Update the playlist name in the box.
                  final key = playlist.key;
                  playlist.name = newName;
                  playlistBox.put(key, playlist);
                  setState(() {
                    playlistname = newName;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show a confirmation dialog before deleting the playlist.
  void _showDeleteConfirmationDialog(Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          title: const Text(
            "Delete Playlist",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Are you sure you want to delete the playlist '${playlist.name}'?",
            style: const TextStyle(color: Colors.white),
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
              onPressed: () async {
                await playlistBox.delete(playlist.key);
                Navigator.pop(context);
                Navigator.pop(context); // Return to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      "Playlist '${playlist.name}' deleted!",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  /// Navigate to the song selection screen for adding songs.
  void _openSongSelectionScreen(Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongSelectionScreen(
          playlist: playlist,
          songss: widget.allsongs,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSongs = widget.songs.isNotEmpty;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Header Section
            Stack(
              children: [
                Container(
                  height: 300,
                  color: AppColors.primaryColor,
                  width: 500,
                  child: hasSongs
                      ? QueryArtworkWidget(
                          id: widget.songs!.last.id,
                          type: ArtworkType.AUDIO,
                          size: 500,
                          artworkFit: BoxFit.cover,
                          nullArtworkWidget: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 60, // Icon size for missing artwork
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                ),
                Positioned(
                  top: 40,
                  left: 15,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),

                // Title Section
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.graphic_eq,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        playlistname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                    onPressed: _showPlaylistOptions,
                  ),
                ),
              ],
            ),
            Expanded(
              child: hasSongs
                  ? ListView.builder(
                      itemCount: widget.songs!.length,
                      itemBuilder: (context, index) {
                        final song = widget.songs![index];
                        return SongTile(
                            song: widget.songs![index],
                            songs: widget.songs!,
                            index: index,
                            onMoreOptions: (context, song) {
                              showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              // Logic to remove the song from the playlist
                                              setState(() {
                                                widget.songs!.removeAt(index);
                                              });
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${song.title} removed from playlist.'),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    color: Colors.red),
                                                SizedBox(width: 10),
                                                Text("Remove from Playlist"),
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          TextButton(
                                            onPressed: () {
                                              // Logic to add the song to favorites
                                              Navigator.pop(
                                                  context); // Close the BottomSheet
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${song.title} added to Favourites.'),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.favorite,
                                                    color: Colors.pink),
                                                SizedBox(width: 10),
                                                Text("Add to Favourites"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            onSongTap: (index, songs) {
                              // Update playlist and play the selected song
                              PlayerController.songsNotifier.value =
                                  List.from(songs);
                              PlayerController.songsNotifier.notifyListeners();

                              // Set the selected song index
                              PlayerController.currentIndex.value = index;

                              // Play the selected song
                              PlayerController.setSong(songs[index]);
                            });
                      },
                    )
                  : Center(
                      child: Text(
                        'No songs in this playlist.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
