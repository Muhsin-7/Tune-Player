import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/material.dart';
import 'package:tune_player/screens/splash_screen.dart';
import 'db/music_model.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(PlaylistAdapter());
  Hive.registerAdapter(FavoriteAdapter());
  Hive.registerAdapter(RecentlyPlayedAdapter());
  Hive.registerAdapter(MostRecentlyPlayedAdapter());
  Hive.registerAdapter(HiveSongAdapter());
  Hive.registerAdapter(AllsongsAdapter());
  // Hive.deleteBoxFromDisk('playlists');
  // Open boxes
  await Hive.openBox<Playlist>('playlists');
  await Hive.openBox<Favorite>('favorites');
  await Hive.openBox<RecentlyPlayed>('recently_played');
  await Hive.openBox<MostRecentlyPlayed>('most_recently_played');
  await Hive.openBox<HiveSong>('song');
  await Hive.openBox<Allsongs>('allsongs');

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tune Player',
          theme: ThemeData(
              scaffoldBackgroundColor:
                  const Color.fromARGB(255, 255, 255, 255)),
          home: Splashscreen()),
    );
  }
}
