// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseHiveAdapter extends TypeAdapter<ExpenseHive> {
  @override
  final int typeId = 0;

  @override
  ExpenseHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseHive()
      ..expenseId = fields[0] as String
      ..name = fields[1] as String
      ..amount = fields[2] as double
      ..date = fields[3] as DateTime
      ..description = fields[4] as String?
      ..categoryId = fields[5] as String
      ..categoryName = fields[6] as String
      ..categoryIconCodePoint = fields[7] as int
      ..categoryColorValue = fields[8] as int;
  }

  @override
  void write(BinaryWriter writer, ExpenseHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.expenseId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.categoryId)
      ..writeByte(6)
      ..write(obj.categoryName)
      ..writeByte(7)
      ..write(obj.categoryIconCodePoint)
      ..writeByte(8)
      ..write(obj.categoryColorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
