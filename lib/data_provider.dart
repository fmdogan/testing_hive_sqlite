import 'model.dart';

List<Message> getMessages() {
  List<Message> myList = List.generate(5000, (index) {
    return Message(
      id: index,
      chatId: 1,
      text: 'text $index',
      sender: 'senderID',
      time: DateTime.now(),
      seenTime: DateTime.now(),
    );
  });
  return myList;
}
