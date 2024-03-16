import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';

int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

Future<void> sendMessage({
  required String myProfilePicture,
  required String otherProfilePicture,
  required String myUserName,
  required String otherUserName,
  required String myUserId,
  required String otherUserId,
  required String replyTo,
  required String text,
  required List<dynamic> image,
  required String myToken,
  required String otherToken,
}) async {

  final String randomUrl = randomAlphaNumeric(16);

  final message = {
    "myProfilePicture": myProfilePicture,
    "otherProfilePicture": otherProfilePicture,
    "myUserName": myUserName,
    "otherUserName": otherUserName,
    "myUserId": myUserId,
    "otherUserId": otherUserId,
    "replyTo": replyTo,
    "text": text,
    "images": image,
    "reactions": [],
    "timeStamp": millisecondsSinceEpoch,
    'dbTimeStamp': FieldValue.serverTimestamp(),
    "chatId": randomUrl,
    "isRead": false,
    "recipientToken": myToken,
    "senderToken": otherToken,
  };

  try {
    String? chatId;
    String chatDocumentId = "${myUserId}${otherUserId}";
    String alternativeId = "${otherUserId}${myUserId}";

    // Check if the document exists with the first combination
    var firstSnapshot = await FirebaseFirestore.instance
        .collection('chats').doc(chatDocumentId).get();

    var secondSnapshot = await FirebaseFirestore.instance
        .collection('chats').doc(alternativeId).get();

    if (firstSnapshot.exists) {
      chatId = chatDocumentId; // Document exists, return its ID
    }
    else if (secondSnapshot.exists) {
      chatId = alternativeId; // Document exists, return its ID
    }
    else {
      chatId = chatDocumentId;
    }







    await FirebaseFirestore.instance.collection('chats').doc("${chatId}").set(
        {
          "profilePictures": [myProfilePicture, otherProfilePicture],
          "userNames": [myUserName, otherUserName],
          "userTokens": [myToken, otherToken],
          "userIds": [myUserId, otherUserId],
          "messageId": "${chatId}",
          "chatId": randomUrl,
          "text": text,
          "timeStamp": millisecondsSinceEpoch,
          'dbTimeStamp': FieldValue.serverTimestamp(),
          "block": false
        }
    );

    await FirebaseFirestore.instance.collection('chats').doc("${chatId}")
        .collection('${chatId}').doc("$randomUrl").set(message);
  } catch (e) {
    print("Error sending message: $e");
  }
}
