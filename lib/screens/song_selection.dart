import 'package:flutter/material.dart';


import '../db/dbfunctions/music_functions.dart';
import '../db/music_model.dart';
import '../widgets/colors.dart';

class SongSelectionScreen extends StatefulWidget {
  final Playlist playlist;
  final List<HiveSong> songss;

  const SongSelectionScreen(
      {super.key, required this.playlist, required this.songss});

  @override
  State<SongSelectionScreen> createState() => _SongSelectionScreenState();
}

class _SongSelectionScreenState extends State<SongSelectionScreen> {
  Map<int, bool> selectedSongs = {};

  @override
  void initState() {
    super.initState();
    for (var song in widget.songss) {
      selectedSongs[song.id] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount = selectedSongs.values
        .where((isSelected) => isSelected)
        .length; //Counts how many songs the user has selected.

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Songs",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.songss.length,
              itemBuilder: (context, index) {
                HiveSong song = widget.songss[index];
                return ListTile(
                  leading: Checkbox(
                    value: selectedSongs[song.id],
                    onChanged: (bool? value) {
                      setState(() {
                        selectedSongs[song.id] = value!;
                      });
                    },
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
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$selectedCount songs selected",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    List<HiveSong> selectedSongList = widget.songss
                        .where((song) =>
                            selectedSongs[song.id] ==
                            true) // Filter out selected songs
                        .toList();
                    List<HiveSong> convertedSongs =
                        selectedSongList.map((songModel) {
                      return HiveSong(
                          id: songModel.id,
                          title: songModel.title,
                          data: songModel.data);
                    }).toList();

                    addSongsToPlaylist(
                      context,
                      widget.playlist.name,
                      convertedSongs,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Add to Playlist"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
