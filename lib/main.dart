// ignore_for_file: avoid_print

import 'package:db_test/db_helpers/sqlite_helpers.dart';
import 'package:db_test/model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'db_helpers/hive_helpers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Message> myMessages = [];
  final dbHelper = DatabaseHelper.instance;
/*
  final _hiveHelper = HiveHelpers();
  late Box<Message> box;

  void _insertHive() {
    _hiveHelper.insertMessages().whenComplete(
      () async {
        await _hiveHelper.readMessages().then((value) {
          setState(() {
            myMessages = value;
            print(box.length);
            print('myMessages length: ' + myMessages.length.toString());
          });
        });
      },
    );
  }

  void _deleteHive() {
    _hiveHelper.deleteMessages().whenComplete(
      () async {
        await _hiveHelper.readMessages().then((value) {
          setState(() {
            myMessages = value;
            print('myMessages length: ' + myMessages.length.toString());
          });
        });
      },
    );
  }

  openBox() async {
    print('openBox: ' + DateTime.now().toString());
    box = await Hive.openBox<Message>('messages', ).whenComplete(
      () => print('openBox: ' + DateTime.now().toString()),
    );
    print(box.length);
  }*/

  void _insertSql() async {
    print('insert 5k starts: ' + DateTime.now().toString());
    await dbHelper.insertMyMessages().whenComplete(() async {
      await dbHelper.get50Messages().then((value) {
        setState(() {
          myMessages = value;
          print('myMessages length: ' + myMessages.length.toString());
        });
      });
    });
  }

  void _deleteSql() async {
    await dbHelper.deleteAllMessages().whenComplete(() async {
      await dbHelper.get50Messages().then((value) {
        setState(() {
          myMessages = value;
          print('myMessages length: ' + myMessages.length.toString());
        });
      });
    });
  }

  void getMessages() async {
    await dbHelper.get50Messages().then((value) {
      setState(() {
        myMessages = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getMessages();
    //var _hiveHelper = HiveHelpers();
    //_hiveHelper.hiveRagisterAdaptor();
    //_hiveHelper.initialize().whenComplete(() => openBox());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing DBs'),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: myMessages.length,
          itemBuilder: (context, index) {
            return Center(
                child: Column(
              children: [
                Text(myMessages[index].id.toString()),
                Text(myMessages[index].text),
              ],
            ));
          }),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _deleteSql,
            child: const Icon(Icons.remove),
          ),
          FloatingActionButton(
            onPressed: _insertSql,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
