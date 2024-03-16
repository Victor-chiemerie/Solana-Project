import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:needlinc/needlinc/backend/user-account/upload-post.dart';
import 'package:needlinc/needlinc/shared-pages/comments.dart';
import 'package:needlinc/needlinc/shared-pages/chat-pages/messages.dart';
import 'package:needlinc/needlinc/shared-pages/people.dart';
import '../backend/functions/get-user-data.dart';
import '../backend/functions/time-difference.dart';
import '../client-pages/client-profile.dart';
import '../shared-pages/construction.dart';
import '../shared-pages/news-post.dart';
import '../shared-pages/auth-pages/welcome.dart';
import '../shared-pages/home-post.dart';
import '../needlinc-variables/colors.dart';
import '../shared-pages/news.dart';
import '../widgets/bottom-menu.dart';
import '../widgets/page-transition.dart';
import 'business-main.dart';
import 'business-profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// Get The post data from the HomePost widget and send it to the screen for users to view
  Widget displayHomePosts(
      {required BuildContext context,
      required String userName,
      required String userId,
      required String address,
      required String userCategory,
      String? userProfession,
      required String profilePicture,
      required List<String> images,
      required String writeUp,
      required List heartsId,
      required int heartCount,
      required int commentCount,
      required Map<String, dynamic> post,
      required int timeStamp,
      required String postId}) {
    if (images.isNotEmpty && writeUp != "") {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CommentsPage(
                        post: post,
                        sourceOption: 'homePage',
                        ownerOfPostUserId: userId,
                      )));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 12.0),
          color: NeedlincColors.white,
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => userCategory == "Business" ||
                                    userCategory == "Freelancer"
                                ? ExternalBusinessProfilePage(
                                    businessUserId: userId)
                                : ExternalClientProfilePage(
                                    clientUserId: userId,
                                  )),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            profilePicture,
                          ),
                          fit: BoxFit.cover,
                        ),
                        color: NeedlincColors.black3,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text("🟢 ${calculateTimeDifference(timeStamp)}",
                                style: const TextStyle(fontSize: 9)),
                            IconButton(
                                onPressed: () {
                                  bool myAccount = userId ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? true
                                      : false;
                                  homePostBottomMenuBar(
                                      context: context,
                                      myAccount: myAccount,
                                      postId: postId);
                                },
                                icon: const Icon(Icons.more_vert))
                          ],
                        ),
                        if (userCategory == 'Business')
                          Text(
                            '${post['userDetails']['businessName']}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          )
                        else if (userCategory == 'Freelancer')
                          Text(
                            '${post['userDetails']['skillSet']}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          )
                        else
                          Text(
                            userCategory,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        Text("📍$address",
                            style: const TextStyle(
                                fontSize: 12, color: NeedlincColors.black2))
                      ],
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 65, bottom: 10),
                alignment: Alignment.topLeft,
                child: Text(
                  writeUp,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.55,
                  margin: const EdgeInsets.fromLTRB(70.0, 0.0, 10.0, 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(
                        images[0],
                      ),
                      fit: BoxFit.cover,
                    ),
                    color: NeedlincColors.black3,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            UploadPost().uploadHearts(
                                context: context,
                                sourceOption: 'homePage',
                                id: postId,
                                ownerOfPostUserId: userId);
                          },
                          icon: heartsId.contains(
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? const Icon(
                                  Icons.favorite,
                                  size: 22,
                                  color: NeedlincColors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                  size: 22,
                                )),
                      Text("$heartCount", style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CommentsPage(
                                          post: post,
                                          sourceOption: 'homePage',
                                          ownerOfPostUserId: userId,
                                        )));
                          },
                          icon: const Icon(
                            Icons.maps_ugc_outlined,
                            size: 20,
                          )),
                      Text("$commentCount",
                          style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const Construction(),
                        );
                      },
                      icon: const Icon(
                        Icons.bookmark_border,
                        size: 20,
                      )),
                  const SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const Construction(),
                        );
                      },
                      icon: const Icon(
                        Icons.share,
                        size: 20,
                      ))
                ],
              )
            ],
          ),
        ),
      );
    }
    if (images.isNotEmpty && writeUp == "") {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CommentsPage(
                        post: post,
                        sourceOption: 'homePage',
                        ownerOfPostUserId: userId,
                      )));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 12.0),
          color: NeedlincColors.white,
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => userCategory == "Business" ||
                                    userCategory == "Freelancer"
                                ? ExternalBusinessProfilePage(
                                    businessUserId: userId)
                                : ExternalClientProfilePage(
                                    clientUserId: userId,
                                  )),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            profilePicture,
                          ),
                          fit: BoxFit.cover,
                        ),
                        color: NeedlincColors.black3,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text("🟢 ${calculateTimeDifference(timeStamp)}",
                                style: const TextStyle(fontSize: 9)),
                            IconButton(
                              onPressed: () {
                                bool myAccount = userId ==
                                        FirebaseAuth.instance.currentUser!.uid
                                    ? true
                                    : false;
                                homePostBottomMenuBar(
                                    context: context,
                                    myAccount: myAccount,
                                    postId: postId);
                              },
                              icon: const Icon(Icons.more_vert),
                            )
                          ],
                        ),
                        if (userCategory == 'Business')
                          Text(
                            '${post['userDetails']['businessName']}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          )
                        else if (userCategory == 'Freelancer')
                          Text(
                            '${post['userDetails']['skillSet']}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          )
                        else
                          Text(
                            userCategory,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        Text("📍$address",
                            style: const TextStyle(
                                fontSize: 12, color: NeedlincColors.black2))
                      ],
                    ),
                  )
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.55,
                margin: const EdgeInsets.fromLTRB(70.0, 0.0, 10.0, 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(
                      images[0],
                    ),
                    fit: BoxFit.cover,
                  ),
                  color: NeedlincColors.black3,
                  shape: BoxShape.rectangle,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            UploadPost().uploadHearts(
                                context: context,
                                sourceOption: 'homePage',
                                id: postId,
                                ownerOfPostUserId: userId);
                          },
                          icon: heartsId.contains(
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? const Icon(
                                  Icons.favorite,
                                  size: 22,
                                  color: NeedlincColors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                  size: 22,
                                )),
                      Text("$heartCount", style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CommentsPage(
                                          post: post,
                                          sourceOption: 'homePage',
                                          ownerOfPostUserId: userId,
                                        )));
                          },
                          icon: const Icon(
                            Icons.maps_ugc_outlined,
                            size: 20,
                          )),
                      Text("$commentCount",
                          style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const Construction(),
                      );
                    },
                    icon: const Icon(
                      Icons.bookmark_border,
                      size: 20,
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const Construction(),
                      );
                    },
                    icon: const Icon(
                      Icons.share,
                      size: 20,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      );
    }
    if (images.isEmpty && writeUp != "") {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CommentsPage(
                        post: post,
                        sourceOption: 'homePage',
                        ownerOfPostUserId: userId,
                      )));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 12.0),
          color: NeedlincColors.white,
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => userCategory == "Business" ||
                                    userCategory == "Freelancer"
                                ? ExternalBusinessProfilePage(
                                    businessUserId: userId)
                                : ExternalClientProfilePage(
                                    clientUserId: userId,
                                  )),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            profilePicture,
                          ),
                          fit: BoxFit.cover,
                        ),
                        color: NeedlincColors.black3,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text("🟢 ${calculateTimeDifference(timeStamp)}",
                                style: const TextStyle(fontSize: 9)),
                            IconButton(
                                onPressed: () {
                                  bool myAccount = userId ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? true
                                      : false;
                                  homePostBottomMenuBar(
                                      context: context,
                                      myAccount: myAccount,
                                      postId: postId);
                                },
                                icon: const Icon(Icons.more_vert))
                          ],
                        ),
                        if (userCategory == 'Business')
                          Text(
                            '${post['userDetails']['businessName']}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          )
                        else if (userCategory == 'Freelancer')
                          Text(
                            '${post['userDetails']['skillSet']}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          )
                        else
                          Text(
                            userCategory,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        Text("📍$address",
                            style: const TextStyle(
                                fontSize: 12, color: NeedlincColors.black2))
                      ],
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 65, bottom: 10),
                alignment: Alignment.topLeft,
                child: Text(
                  writeUp,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            UploadPost().uploadHearts(
                                context: context,
                                sourceOption: 'homePage',
                                id: postId,
                                ownerOfPostUserId: userId);
                          },
                          icon: heartsId.contains(
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? const Icon(
                                  Icons.favorite,
                                  size: 22,
                                  color: NeedlincColors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                  size: 22,
                                )),
                      Text('$heartCount', style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CommentsPage(
                                          post: post,
                                          sourceOption: 'homePage',
                                          ownerOfPostUserId: userId,
                                        )));
                          },
                          icon: const Icon(
                            Icons.maps_ugc_outlined,
                            size: 20,
                          )),
                      Text("$commentCount",
                          style: const TextStyle(fontSize: 15))
                    ],
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const Construction(),
                        );
                      },
                      icon: const Icon(
                        Icons.bookmark_border,
                        size: 20,
                      )),
                  const SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const Construction(),
                        );
                      },
                      icon: const Icon(
                        Icons.share,
                        size: 20,
                      ))
                ],
              )
            ],
          ),
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  //Get Data from firebase and send it to the Display widget
  Widget HomePosts(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('homePage')
            .orderBy('postDetails.timeStamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          else if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            List<DocumentSnapshot> dataList = snapshot.data!.docs;
            return ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (BuildContext context, int index) {
                  var data = dataList[index].data() as Map<String, dynamic>;
                  Map<String, dynamic>? userDetails = data['userDetails'];
                  Map<String, dynamic>? postDetails = data['postDetails'];

                  if (userDetails == null || postDetails == null) {
                    return const Center(child: Text("User details not found"));
                  }

                  // Cast images list to List<String>
                  List<String> images =
                      List<String>.from(postDetails['images']);

                  return displayHomePosts(
                    context: context,
                    userName: userDetails['userName'],
                    userId: userDetails['userId'],
                    address: userDetails['address'],
                    userCategory: userDetails['userCategory'],
                    userProfession: userDetails['skillSets'],
                    profilePicture: userDetails['profilePicture'],
                    images: images,
                    writeUp: postDetails['writeUp'],
                    heartCount: postDetails['hearts'].length,
                    heartsId: postDetails['hearts'],
                    commentCount: postDetails['comments'].length,
                    post: data,
                    postId: postDetails['postId'],
                    timeStamp: postDetails['timeStamp'],
                  );
                });
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const WelcomePage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // This is the AppBar
        appBar: AppBar(
            backgroundColor: NeedlincColors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
            iconTheme: const IconThemeData(color: NeedlincColors.blue1),
            title: const Text(
              "Needlinc",
              style: TextStyle(fontSize: 15, color: NeedlincColors.blue1),
            ),
            actions: [
              Row(
                children: [
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    icon: const Icon(Icons.people),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PeoplePage()),
                      );
                    },
                  ),
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    icon: const Icon(Icons.message),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Messages()),
                      );
                    },
                  ),
                ],
              ),
            ]),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return const Text("Document does not exist");
            }
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> userData =
                  snapshot.data!.data() as Map<String, dynamic>;
              return Stack(
                children: [
                  // Write a post section
                  SizedBox(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            userData['userCategory'] == 'Blogger'
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NewsPostPage()),
                                  )
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePostPage()),
                                  );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: NeedlincColors.black3,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Profile Picture
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BusinessMainPages(
                                                      currentPage: 4)),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(15.0),
                                        margin: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              userData['profilePicture'],
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                          color: NeedlincColors.black3,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    // Write a post
                                    InkWell(
                                        onTap: () {
                                          userData['userCategory'] == 'Blogger'
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const NewsPostPage()),
                                                )
                                              : Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const HomePostPage()),
                                                );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: userData['userCategory'] ==
                                                  'Blogger'
                                              ? const Text(
                                                  "Make an announcement...")
                                              : const Text("Write a post..."),
                                        ))
                                  ],
                                ),
                                // Select Gallary or Camera icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 50.0,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          userData['userCategory'] == 'Blogger'
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const NewsPostPage()),
                                                )
                                              : Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const HomePostPage()),
                                                );
                                        },
                                        icon: const Icon(
                                          Icons.photo_library_outlined,
                                          color: NeedlincColors.blue1,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          userData['userCategory'] == 'Blogger'
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const NewsPostPage()),
                                                )
                                              : Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const HomePostPage()),
                                                );
                                        },
                                        icon: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: NeedlincColors.blue1,
                                        ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        // (This is the News Icon close to the write a post page)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context, SizeTransition5(const NewsPage()));
                          },
                          child: Container(
                            alignment: Alignment.topCenter,
                            height: 55,
                            margin: const EdgeInsets.only(
                                left: 16.0, right: 10.0, top: 8.0),
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: NeedlincColors.blue1,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.newspaper,
                                    color: NeedlincColors.white, size: 30.0),
                                Text("News",
                                    style: TextStyle(
                                        color: NeedlincColors.white,
                                        fontSize: 10.0)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  HomePosts(context)
                ],
              );
            }
            // While waiting for the data to be fetched, show a loading indicator
            return const Center(child: CircularProgressIndicator());
          },
        )
    );
  }
}
