// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerModelAdapter extends TypeAdapter<PlayerModel> {
  @override
  final int typeId = 0;

  @override
  PlayerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      score: fields[2] as int,
      secretNumber: fields[3] as String?,
      guesses: (fields[4] as List).cast<String>(),
      guessResults: (fields[5] as List).cast<GuessResultModel>(),
      isCurrentPlayer: fields[6] as bool,
      hasWon: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.secretNumber)
      ..writeByte(4)
      ..write(obj.guesses)
      ..writeByte(5)
      ..write(obj.guessResults)
      ..writeByte(6)
      ..write(obj.isCurrentPlayer)
      ..writeByte(7)
      ..write(obj.hasWon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GuessResultModelAdapter extends TypeAdapter<GuessResultModel> {
  @override
  final int typeId = 1;

  @override
  GuessResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuessResultModel(
      guess: fields[0] as String,
      digitResults: (fields[1] as List).cast<DigitResultModel>(),
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GuessResultModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.guess)
      ..writeByte(1)
      ..write(obj.digitResults)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuessResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DigitResultModelAdapter extends TypeAdapter<DigitResultModel> {
  @override
  final int typeId = 2;

  @override
  DigitResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DigitResultModel(
      digit: fields[0] as String,
      position: fields[1] as int,
      status: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DigitResultModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.digit)
      ..writeByte(1)
      ..write(obj.position)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DigitResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
