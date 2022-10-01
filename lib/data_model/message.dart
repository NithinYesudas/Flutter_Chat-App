import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
part "message.g.dart";

@HiveType(typeId: 0)
class Message extends HiveObject {
  Message(
      {required this.message,
      required this.msgId,
      required this.seenStatus,
      required this.time,
      this.imageUrl});
  @HiveField(0)
  String message;
  @HiveField(1)
  String? imageUrl;
  @HiveField(2)
  String msgId;
  @HiveField(3)
  Timestamp time;
  @HiveField(4)
  String seenStatus;
}
