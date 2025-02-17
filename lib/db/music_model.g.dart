// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllsongsAdapter extends TypeAdapter<Allsongs> {
  @override
  final int typeId = 0;

  @override
  Allsongs read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Allsongs()..allsongsss = (fields[0] as List?)?.cast<HiveSong>();
  }

  @override
  void write(BinaryWriter writer, Allsongs obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.allsongsss);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllsongsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 1;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      name: fields[0] as String,
      songs: (fields[1] as List?)?.cast<HiveSong>(),
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.songs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveSongAdapter extends TypeAdapter<HiveSong> {
  @override
  final int typeId = 2;

  @override
  HiveSong read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSong(
      id: fields[0] as int,
      title: fields[1] as String,
      data: fields[2] as String,
      artist: fields[3] as String?,
      album: fields[4] as String?,
      duration: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSong obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.album)
      ..writeByte(5)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavoriteAdapter extends TypeAdapter<Favorite> {
  @override
  final int typeId = 3;

  @override
  Favorite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Favorite(
      id: fields[0] as int,
      title: fields[1] as String,
      data: fields[2] as String,
      artist: fields[3] as String?,
      album: fields[4] as String?,
      duration: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Favorite obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.album)
      ..writeByte(5)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecentlyPlayedAdapter extends TypeAdapter<RecentlyPlayed> {
  @override
  final int typeId = 4;

  @override
  RecentlyPlayed read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentlyPlayed(
      id: fields[0] as int,
      title: fields[1] as String,
      data: fields[2] as String,
      artist: fields[3] as String?,
      album: fields[4] as String?,
      duration: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RecentlyPlayed obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.album)
      ..writeByte(5)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentlyPlayedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MostRecentlyPlayedAdapter extends TypeAdapter<MostRecentlyPlayed> {
  @override
  final int typeId = 5;

  @override
  MostRecentlyPlayed read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MostRecentlyPlayed(
      id: fields[0] as int,
      title: fields[1] as String,
      data: fields[2] as String,
      artist: fields[3] as String?,
      album: fields[4] as String?,
      duration: fields[5] as int?,
      playCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MostRecentlyPlayed obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.album)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.playCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MostRecentlyPlayedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
