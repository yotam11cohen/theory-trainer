// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressEventAdapter extends TypeAdapter<ProgressEvent> {
  @override
  final int typeId = 3;

  @override
  ProgressEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressEvent(
      lessonId: fields[0] as String,
      score: fields[1] as int,
      earnedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressEvent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.earnedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
