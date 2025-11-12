// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryHiveAdapter extends TypeAdapter<CategoryHive> {
  @override
  final int typeId = 1;

  @override
  CategoryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryHive()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..icon = fields[2] as String
      ..color = fields[3] as String
      ..isPredefined = fields[4] as bool
      ..userId = fields[5] as String?
      ..syncedAt = fields[6] as DateTime?
      ..updatedAt = fields[7] as DateTime
      ..isDeleted = fields[8] as bool;
  }

  @override
  void write(BinaryWriter writer, CategoryHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.isPredefined)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.syncedAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
