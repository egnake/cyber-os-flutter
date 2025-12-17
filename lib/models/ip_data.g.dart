// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ip_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IpDataAdapter extends TypeAdapter<IpData> {
  @override
  final int typeId = 0;

  @override
  IpData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IpData(
      ip: fields[0] as String,
      country: fields[1] as String,
      city: fields[2] as String,
      isp: fields[3] as String,
      lat: fields[4] as double,
      lon: fields[5] as double,
      openPorts: (fields[6] as List).cast<String>(),
      riskScore: fields[7] as int,
      queryDate: fields[8] as DateTime?,
      originalQuery: fields[9] as String,
      org: fields[10] as String,
      timezone: fields[11] as String,
      isMobile: fields[12] as bool,
      isProxy: fields[13] as bool,
      isHosting: fields[14] as bool,
      httpHeaders: (fields[15] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, IpData obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.ip)
      ..writeByte(1)
      ..write(obj.country)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.isp)
      ..writeByte(4)
      ..write(obj.lat)
      ..writeByte(5)
      ..write(obj.lon)
      ..writeByte(6)
      ..write(obj.openPorts)
      ..writeByte(7)
      ..write(obj.riskScore)
      ..writeByte(8)
      ..write(obj.queryDate)
      ..writeByte(9)
      ..write(obj.originalQuery)
      ..writeByte(10)
      ..write(obj.org)
      ..writeByte(11)
      ..write(obj.timezone)
      ..writeByte(12)
      ..write(obj.isMobile)
      ..writeByte(13)
      ..write(obj.isProxy)
      ..writeByte(14)
      ..write(obj.isHosting)
      ..writeByte(15)
      ..write(obj.httpHeaders);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IpDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
