import 'package:chatapp/screens/messages.dart';
import 'package:hive_flutter/adapters.dart';

class Boxes {
  static Box getMessages() => Hive.box('messages');
}
