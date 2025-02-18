import 'package:flutter/material.dart';
import 'package:tune_player/screens/playlist_songs.dart';
import 'package:tune_player/screens/playlists.dart';
import 'package:tune_player/screens/recently_Played.dart';


import '../db/music_model.dart';
import '../widgets/colors.dart';
import '../widgets/mini_player.dart';
import 'favorites.dart';
import 'home_page.dart';
import 'mostplayed.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Widget? _currentScreen;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentScreen = Homepage();
    _screens = [
      Homepage(),
      Playlistspage(onPlaylistTap: _navigateToPlaylistSongs),
      Favourites(),
      Recentlyplayed(),
      Mostplayed(),
    ];
  }

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
      _currentScreen = _screens[index];
    });
  }

  void _navigateToPlaylistSongs(
      String playlistName, List<HiveSong> songs, List<HiveSong> allsongs) {
    setState(() {
      _currentScreen = PlaylistSongs(
        playlistName: playlistName,
        songs: songs,
        allsongs: allsongs,
        onBack: () {
          setState(() {
            _currentScreen = Playlistspage(
              onPlaylistTap: _navigateToPlaylistSongs,
            );
          });
        },
      );
    });
  }

  // List of Screens



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentScreen!,
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayerWidget(), // MiniPlayer remains at bottom
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateTo,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.queue_music), label: 'Playlists'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Recent'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: 'Most Played'),
        ],
      ),
    );
  }
}
