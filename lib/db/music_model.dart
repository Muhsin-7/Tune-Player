// ignore: depend_on_referenced_packages
import 'package:hive/hive.dart';

part 'music_model.g.dart'; // the content of this file is part of another file.

@HiveType(typeId: 0)
class Allsongs extends HiveObject {
  @HiveField(0)
  List<HiveSong>? allsongsss;
}

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<HiveSong>? songs;

  Playlist({required this.name, required this.songs});
}

@HiveType(typeId: 2) // Assign a unique typeId for this class.
class HiveSong {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String data;

  @HiveField(3)
  String? artist;

  @HiveField(4)
  String? album;

  @HiveField(5)
  int? duration;

  HiveSong({
    required this.id,
    required this.title,
    required this.data,
    this.artist,
    this.album,
    this.duration,
  });
}

@HiveType(typeId: 3)
class Favorite extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String data;

  @HiveField(3)
  String? artist;

  @HiveField(4)
  String? album;

  @HiveField(5)
  int? duration;

  Favorite({
    required this.id,
    required this.title,
    required this.data,
    this.artist,
    this.album,
    this.duration,
  });
}

@HiveType(typeId: 4)
class RecentlyPlayed extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String title;

  @HiveField(2)
  String data;

  @HiveField(3)
  String? artist;

  @HiveField(4)
  String? album;

  @HiveField(5)
  int? duration;

  RecentlyPlayed({
    required this.id,
    required this.title,
    required this.data,
    this.artist,
    this.album,
    this.duration,
  });
}

@HiveType(typeId: 5)
class MostRecentlyPlayed extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String title;

  @HiveField(2)
  String data;

  @HiveField(3)
  String? artist;

  @HiveField(4)
  String? album;

  @HiveField(5)
  int? duration;

  @HiveField(6)
  int playCount;

  MostRecentlyPlayed(
      {required this.id,
      required this.title,
      required this.data,
      this.artist,
      this.album,
      this.duration,
      required this.playCount});
}
