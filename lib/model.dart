import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late int chatId;

  @HiveField(2)
  late String text;

  @HiveField(3)
  late String sender;

  @HiveField(4)
  late DateTime time;

  @HiveField(5)
  late DateTime seenTime;

  Message({
    required this.id,
    required this.chatId,
    required this.text,
    required this.sender,
    required this.time,
    required this.seenTime,
  });

  Map toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'text': text,
      'sender': sender,
      'time': time.toString(),
      'seenTime': seenTime.toString(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chatId'],
      text: json['text'],
      sender: json['sender'],
      time: json['time'],
      seenTime: json['seenTime'],
    );
  }

  Map<String, dynamic> toSqlMap() {
    return {
      'chatId': chatId,
      'text': text,
      'sender': sender,
      'time': time.toString(),
      'seenTime': seenTime.toString(),
    };
  }

  factory Message.fromSqlMap(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chatId'],
      text: json['text'],
      sender: json['sender'],
      time: DateTime.tryParse((json['time'])) ?? DateTime.now(),
      seenTime: DateTime.tryParse((json['seenTime'])) ?? DateTime.now(),
    );
  }
}

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final typeId = 0;

  @override
  Message read(BinaryReader reader) {
    return Message(
      id: reader.read(),
      chatId: reader.read(),
      text: reader.read(),
      sender: reader.read(),
      time: reader.read(),
      seenTime: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer.write(obj.id);
    writer.write(obj.chatId);
    writer.write(obj.text);
    writer.write(obj.sender);
    writer.write(obj.time);
    writer.write(obj.seenTime);
  }
}
