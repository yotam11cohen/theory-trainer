// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserCacheAdapter extends TypeAdapter<UserCache> {
  @override
  final int typeId = 2;

  @override
  UserCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserCache(
      totalXp: fields[0] as int,
      level: fields[1] as int,
      streakCount: fields[2] as int,
      lastActive: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalXp)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.streakCount)
      ..writeByte(3)
      ..write(obj.lastActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
