import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:needlinc/needlinc/backend/functions/time-difference.dart";
import "package:needlinc/needlinc/backend/user-account/delete-post.dart";
import 'package:needlinc/needlinc/needlinc-variables/colors.dart';
import 'package:needlinc/needlinc/shared-pages/chat-pages/chat_screen.dart';

import "../construction.dart";

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<DocumentSnapshot> searchResults = [];
  bool isSearching = false;
  late String myUserId;
  late String myUserName;
  late String myProfilePicture;
  Stream<QuerySnapshot>? chatsStream;

  void getMyNameAndmyUserId() async {
    myUserId = await FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> myInitUserName =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(myUserId)
            .get();
    myUserName = myInitUserName['userName'];
    myProfilePicture = myInitUserName['profilePicture'];

    chatsStream = FirebaseFirestore.instance
        .collection('chats')
        .where('userIds', arrayContains: myUserId)
        .orderBy('timeStamp', descending: true)
        .snapshots();
    setState(() {});
  }

  // This function will be called when a search is performed
  void searchUsers(String searchQuery) async {
    String searchLower = searchQuery.trim().toLowerCase();
    if (searchLower.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    String searchUpper;
    if (searchLower.length > 1) {
      searchUpper = searchLower.substring(0, searchLower.length - 1) +
          String.fromCharCode(
              searchLower.codeUnitAt(searchLower.length - 1) + 1);
    } else {
      // If the search query is a single character, handle differently
      int lastChar = searchLower.codeUnitAt(0);
      if (lastChar < 0xD7FF || (lastChar > 0xE000 && lastChar < 0xFFFD)) {
        // If it's a regular character, just increment it
        searchUpper = String.fromCharCode(lastChar + 1);
      } else {
        // If it's a special character, consider an alternative appoach
        searchUpper = searchLower +
            'z'; // This may need adjustment based on your use case
      }
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('userName')
        .startAt([searchLower]).endAt([searchUpper]).get();

    setState(() {
      searchResults = querySnapshot.docs;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getMyNameAndmyUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          iconSize: 20,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: IconThemeData(color: Colors.blue),
        title: Text(
          "MESSAGES",
          style: TextStyle(color: Colors.blue, fontSize: 12),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const Construction(),
                );
              },
              iconSize: 25,
              icon: Icon(Icons.more_vert))
        ],
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          //TODO Search bar
          Container(
            height: 35,
            width: 400,
            margin: EdgeInsets.only(left: 50, right: 50),
            padding: EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: NeedlincColors.black3,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search,
                  color: NeedlincColors.blue1,
                ),
                SizedBox(width: 1),
                VerticalDivider(
                  thickness: 2,
                ),
                SizedBox(width: 1),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                    ),
                    onChanged: searchUsers,
                  ),
                ),
              ],
            ),
          ),

          Container(
              margin: EdgeInsets.only(top: 40),
              child: isSearching
                  ? ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (BuildContext context, int index) {
                        var user =
                            searchResults[index].data() as Map<String, dynamic>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        myProfilePicture: myProfilePicture,
                                        otherProfilePicture:
                                            user['profilePicture'],
                                        otherUserId: user['userId'],
                                        myUserId: myUserId,
                                        myUserName: myUserName,
                                        otherUserName: user['userName'],
                                        nameOfProduct: '')));
                                searchUsers('');
                              },
                              leading: Container(
                                width: 50, // width and height of the Container
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape
                                      .circle, // Makes the container circular
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        "${user['profilePicture']}"), // Path to your image
                                    fit: BoxFit
                                        .cover, // Ensures the image covers the container
                                  ),
                                ),
                              ),
                              title: Text(
                                user['userName'],
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Divider(
                                thickness: 1.2, color: NeedlincColors.black2),
                          ],
                        );
                      },
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: chatsStream ??
                          FirebaseFirestore.instance
                              .collection('users')
                              .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var chats = snapshot.data?.docs ?? [];

                        return chats.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                    "You can search for clients, traders, customers, freelancers and bloggers to chat with",
                                    style: TextStyle(
                                      color: NeedlincColors.black2,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    )),
                              )
                            : ListView.builder(
                                itemCount: chats.length,
                                itemBuilder: (context, index) {
                                  var chat = chats[index].data()
                                      as Map<String, dynamic>;

                                  // Assuming 'myUserId' is the current user's ID
                                  int otherUserIndex =
                                      chat["userIds"].indexOf(myUserId) == 0
                                          ? 1
                                          : 0;
                                  String otherUserName =
                                      chat["userNames"][otherUserIndex];
                                  String otherUserProfilePicture =
                                      chat["profilePictures"][otherUserIndex];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onLongPress: () {
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible:
                                                false, // User must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Delete Message'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      Text(
                                                          'Do you want to proceed with this action?'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  // "Yes" button
                                                  TextButton(
                                                    child: Text('Yes'),
                                                    onPressed: () {
                                                      DeletePost()
                                                          .deleteMessagePost(
                                                              context: context,
                                                              chatCollection: chat[
                                                                  'messageId']);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  // "No" button
                                                  TextButton(
                                                    child: Text('No'),
                                                    onPressed: () {
                                                      // Perform action when user selects "No"
                                                      Navigator.of(context).pop(
                                                          false); // Close dialog and return false
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                          myProfilePicture:
                                                              myProfilePicture,
                                                          otherProfilePicture:
                                                              otherUserProfilePicture,
                                                          otherUserId: chat[
                                                                  'userIds']
                                                              [otherUserIndex],
                                                          myUserId: myUserId,
                                                          myUserName:
                                                              myUserName,
                                                          otherUserName:
                                                              otherUserName,
                                                          nameOfProduct: '',
                                                        )));
                                          },
                                          leading: Container(
                                            width:
                                                50, // width and height of the Container
                                            height: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape
                                                  .circle, // Makes the container circular
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    "$otherUserProfilePicture"), // Path to your image
                                                fit: BoxFit
                                                    .cover, // Ensures the image covers the container
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "$otherUserName",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            "${chat['text']}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: Text(
                                            calculateTimeDifference(
                                                chat['timeStamp']),
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: NeedlincColors.black2),
                                          ),
                                        ),
                                      ),
                                      Divider(
                                          thickness: 1.2,
                                          color: NeedlincColors.black2),
                                    ],
                                  );
                                },
                              );
                      },
                    ))
        ],
      ),
    );
  }
}
