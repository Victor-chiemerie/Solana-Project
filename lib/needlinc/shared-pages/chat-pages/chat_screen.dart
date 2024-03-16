import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/material.dart';
import 'package:needlinc/needlinc/needlinc-variables/colors.dart';
import "package:needlinc/needlinc/shared-pages/chat-pages/set_appointment.dart";

import "../../backend/user-account/delete-post.dart";
import "../../backend/user-account/upload-chat.dart";
import "../construction.dart";

class ChatScreen extends StatefulWidget {
  String nameOfProduct;
  final String myProfilePicture;
  final String otherProfilePicture;
  final String myUserId;
  final String otherUserId;
  final String myUserName;
  final String otherUserName;

  // Add a constructor to ChatScreen that takes userId as a parameter
  ChatScreen(
      {Key? key,
      required this.nameOfProduct,
      required this.myProfilePicture,
      required this.otherProfilePicture,
      required this.myUserId,
      required this.otherUserId,
      required this.myUserName,
      required this.otherUserName})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  late String userId = widget.myUserId;
  Stream<QuerySnapshot>? messageStream;
  String? chatCollection;
  late ScrollController _scrollController;

  void getStream() async {
    // Initialize the scroll controller
    _scrollController = ScrollController();
    // Call setState if necessary to refresh the StreamBuilder
    setState(() {});

    String myUserId = widget.myUserId;
    String otherUserId = widget.otherUserId;

    String chatDocumentId = "$myUserId$otherUserId";
    String alternativeId = "$otherUserId$myUserId";

    // Check if the document exists with the first combination
    var firstSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocumentId)
        .get();

    var secondSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(alternativeId)
        .get();

    if (firstSnapshot.exists) {
      chatCollection = chatDocumentId; // Document exists, return its ID
    } else if (secondSnapshot.exists) {
      chatCollection = alternativeId; // Document exists, return its ID
    } else {
      chatCollection = chatDocumentId;
    }

    messageStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatCollection!)
        .collection(chatCollection!)
        .orderBy('dbTimeStamp', descending: true)
        .snapshots();
    // Call setState if necessary to refresh the StreamBuilder
    setState(() {});
  }

  @override
  void initState() {
    //  implement initState
    getStream();
    _textController.text = widget.nameOfProduct != ''
        ? "Good day, I am interested in purchasing a product of yours called ${widget.nameOfProduct}, is it still available?"
        : '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
            color: NeedlincColors.blue1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Makes the container circular
                image: DecorationImage(
                  image: NetworkImage(
                      widget.otherProfilePicture), // Path to your image
                  fit: BoxFit.cover, // Ensures the image covers the container
                ),
              ),
            ),
            Text(
                widget.otherUserName.length > 8
                    ? "${widget.otherUserName.substring(0, 7)}..."
                    : widget.otherUserName,
                style: const TextStyle(
                  color: NeedlincColors.blue1,
                  fontSize: 18,
                )),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.call_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const Construction(),
                );
              },
              color: NeedlincColors.blue1),
          IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const Construction(),
                );
              },
              color: NeedlincColors.blue1),
          IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const Construction(),
                );
              },
              color: NeedlincColors.blue1),
        ],
        backgroundColor: NeedlincColors.white,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messageStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var data = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var chatData = data[index].data()
                        as Map<String, dynamic>; // Access each document's data

                    return Align(
                        alignment: userId == chatData['myUserId']
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: userId == chatData['myUserId'] 
                          ?const EdgeInsets.only(left: 60, top: 5, bottom: 5, right: 5)
                          :const EdgeInsets.only(right: 60, top: 5, bottom: 5, left: 5),
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: userId == chatData['myUserId']
                                ? NeedlincColors.blue2
                                : NeedlincColors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: NeedlincColors.black3.withOpacity(0.8),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onLongPress: () {
                              DeletePost().deleteChatPost(
                                  context: context,
                                  chatCollection: chatCollection!,
                                  chatId: chatData['chatId']);
                            },
                            child: Text(
                              chatData['text']
                                  .replaceAll(RegExp(r'\n\s*\n'), ""),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ));
                  },
                );
              },
            ),
          ),
          //The bottom bar of the app including the message field
          Container(
            padding: const EdgeInsets.all(2),
            color: Colors.white70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_outlined),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const Construction(),
                    );
                  },
                  color: NeedlincColors.blue1,
                ),
                IconButton(
                  icon: const Icon(Icons.mic_outlined),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const Construction(),
                    );
                  },
                  color: NeedlincColors.blue1,
                ),

                // Adjust the size of the message textfield ensuring that text goes to the next line
                // Message typing feature, behaviour and properties
                Container(
                  width: MediaQuery.of(context).size.width * 0.60,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    border: Border.all(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                          ),
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintText: "Message...",
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            onSubmitted: (text) {
                              sendMessage(
                                  myProfilePicture: widget.myProfilePicture,
                                  otherProfilePicture:
                                      widget.otherProfilePicture,
                                  myUserName: widget.myUserName,
                                  otherUserName: widget.otherUserName,
                                  myUserId: widget.myUserId,
                                  otherUserId: widget.otherUserId,
                                  replyTo: '',
                                  text: _textController.text,
                                  image: [],
                                  myToken: '',
                                  otherToken: '');
                              setState(() {
                                _textController.clear();
                              });
                            },
                          ),
                        ),
                      ),

                      //Send button in the message field
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            sendMessage(
                                myProfilePicture: widget.myProfilePicture,
                                otherProfilePicture:
                                    widget.otherProfilePicture,
                                myUserName: widget.myUserName,
                                otherUserName: widget.otherUserName,
                                myUserId: widget.myUserId,
                                otherUserId: widget.otherUserId,
                                replyTo: '',
                                text: _textController.text,
                                image: [],
                                myToken: '',
                                otherToken: '');
                            setState(() {
                              _textController.clear();
                            });
                          }
                        },
                        color: NeedlincColors.blue1,
                      ),
                    ],
                  ),
                ),

                //Calendar feature and properties
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          showDialog(
                            context: context, 
                            builder: (context) => const Construction() //Replace this with the action to push to the set_appointment
                            );
                        }, // Implement an action
                        color: NeedlincColors.blue1),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
