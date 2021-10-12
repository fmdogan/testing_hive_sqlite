import 'dart:io';

import 'package:db_test/data_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../model.dart';

class HiveHelpers {
  void hiveRagisterAdaptor() {
    Hive.registerAdapter(MessageAdapter());
  }

  Future initialize() async {
    await path_provider.getApplicationDocumentsDirectory().then(
          (directory) async => await Hive.initFlutter(directory.path),
        );
    //await Hive.initFlutter();
  }

  Future insertMessages() async {
    var box = Hive.box<Message>('messages');
    var messageList = getMessages();
    // ignore: avoid_print
    print('insert 5000 messages starts: ' + DateTime.now().toString());

    await box.addAll(messageList).whenComplete(() async => {
          // ignore: avoid_print
          print('insert 5000 messages ends: ' + DateTime.now().toString()),
          box.compact(),
        });
  }

  Future deleteMessages() async {
    var box = Hive.box<Message>('messages');

    // ignore: avoid_print
    print('delete messages start: ' + DateTime.now().toString());

    await box.clear().whenComplete(() async => {
          // ignore: avoid_print
          print('delete messages end: ' + DateTime.now().toString()),
        });
  }

  Future<List<Message>> readMessages() async {
    List<Message> messageList = [];

    var box = Hive.box<Message>('messages');

    // ignore: avoid_print
    print('read 50 messages: ' + DateTime.now().toString());
    //if (box.isNotEmpty) {
    //  for (int i = 0; i < 50; i++) {
    //    await box.getAt(box.length - i - 1).then((value) {
    //      if (value != null) {
    //        messageList.add(value);
    //      }
    //    });
    //  }
    //}
    messageList = box.valuesBetween(startKey: box.length - 50).toList();

    // ignore: avoid_print
    print('read 50 messages: ' + DateTime.now().toString());
    return box.values.toList();
  }
}
