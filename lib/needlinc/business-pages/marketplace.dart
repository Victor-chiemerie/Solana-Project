import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:needlinc/needlinc/backend/user-account/functionality.dart';
import 'package:needlinc/needlinc/shared-pages/product-details.dart';
import '../backend/functions/time-difference.dart';
import '../backend/user-account/upload-post.dart';
import '../client-pages/client-profile.dart';
import '../shared-pages/chat-pages/chat_screen.dart';
import '../shared-pages/construction.dart';
import '../shared-pages/market-place-post.dart';
import 'package:needlinc/needlinc/business-pages/business-main.dart';
import 'package:needlinc/needlinc/shared-pages/comments.dart';
import '../needlinc-variables/colors.dart';
import 'package:needlinc/needlinc/shared-pages/chat-pages/messages.dart';
import '../widgets/bottom-menu.dart';
import 'business-profile.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  CollectionReference marketPlacePosts =
      FirebaseFirestore.instance.collection('marketPlacePage');
  CollectionReference user = FirebaseFirestore.instance.collection('users');

  List<DocumentSnapshot> searchResults = [];
  bool isSearching = false;

  late String myUserId;
  late String myUserName;
  late String myProfilePicture;

  void getMyNameAndmyUserId() async {
    myUserId = await FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> myInitUserName =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(myUserId)
            .get();
    myUserName = myInitUserName['userName'];
    myProfilePicture = myInitUserName['profilePicture'];
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
        // If it's a special character, consider an alternative approach
        searchUpper =
            '${searchLower}z'; // This may need adjustment based on your use case
      }
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('marketPlacePage')
        .orderBy('productDetails.name')
        .startAt([searchLower]).endAt([searchUpper]).get();

    setState(() {
      searchResults = querySnapshot.docs;
    });
  }

  @override
  void initState() {
    // implement initState
    getMyNameAndmyUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // This is the AppBar
        appBar: AppBar(
          backgroundColor: NeedlincColors.white,
          automaticallyImplyLeading: false,
          elevation: 5.0,
          shadowColor: NeedlincColors.black1,
          iconTheme: const IconThemeData(color: NeedlincColors.blue1),
          title: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: const Text(
                    "MARKET PLACE",
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Container(
                height: 35,
                width: 300,
                margin: const EdgeInsets.only(bottom: 5.0, top: 7.5),
                padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
                decoration: BoxDecoration(
                  color: NeedlincColors.black3,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.search),
                    const SizedBox(width: 2.0),
                    const VerticalDivider(
                      thickness: 2,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          // Perform search action here
                          searchUsers(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      icon: const Icon(Icons.message),
                      onPressed: () {
                        // Chat messaging feature
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Messages()),
                        );
                      },
                    ),
                    // This container is for the small circular profile  picture  at the app bar in the market place page
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BusinessMainPages(currentPage: 4)));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              "${getUserData('profilePicture') ?? 'https://tpc.googlesyndication.com/simgad/9072106819292482259?sqp=-oaymwEMCMgBEMgBIAFQAVgB&rs=AOga4qn5QB4xLcXAL0KU8kcs5AmJLo3pow'} ",
                            ),
                            fit: BoxFit.fill,
                          ),
                          color: NeedlincColors.black3,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                // This is the post button in the market-place page
                Container(
                  width: 45,
                  height: 40,
                  decoration: BoxDecoration(
                    color: NeedlincColors.blue1,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    icon: const Icon(
                      Icons.draw_outlined,
                      color: NeedlincColors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MarketPlacePostPage()));
                    },
                  ),
                ),
              ],
            ),
          ],
          toolbarHeight: 95,
        ),
        body: isSearching
            ? ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  var data =
                      searchResults[index].data() as Map<String, dynamic>;
                  Map<String, dynamic>? userDetails = data['userDetails'];
                  Map<String, dynamic>? productDetails = data['productDetails'];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                    userDetails: data['userDetails'],
                                    productDetails: data['productDetails'],
                                  )));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 6.0),
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 12.0),
                      decoration: BoxDecoration(
                        color: NeedlincColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: NeedlincColors.black3
                                .withOpacity(0.8), // Shadow color
                            spreadRadius: 4, // Spread radius
                            blurRadius: 5, // Blur radius
                            offset: const Offset(
                                0, 6), // Offset in the form of (dx, dy)
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (contex) => userDetails[
                                                        'userCategory'] ==
                                                    "Business" ||
                                                userDetails['userCategory'] ==
                                                    "Freelancer"
                                            ? ExternalBusinessProfilePage(
                                                businessUserId:
                                                    userDetails['userId'])
                                            : ExternalClientProfilePage(
                                                clientUserId:
                                                    userDetails['userId'],
                                              )),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(25),
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        userDetails!["profilePicture"],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    color: NeedlincColors.black3,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          userDetails!["userName"],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text(
                                          "🟢 Now",
                                          style: TextStyle(fontSize: 9),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              bool myAccount =
                                                  userDetails['userId'] ==
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid
                                                      ? true
                                                      : false;
                                              marketPlacePostBottomMenuBar(
                                                  context: context,
                                                  myAccount: myAccount,
                                                  postId: productDetails![
                                                      'productId']);
                                            },
                                            icon: const Icon(Icons.more_vert))
                                      ],
                                    ),
                                    if (userDetails['userCategory'] ==
                                        'Business')
                                      Text(
                                        userDetails['businessName'] != null
                                            ? "~${userDetails['businessName']}"
                                            : 'Business Owner',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      )
                                    else if (userDetails['userCategory'] ==
                                        'Freelancer')
                                      Text(
                                        "~${userDetails['skillSet']}",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      )
                                    else
                                      Text(
                                        "~${userDetails['userCategory']}",
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    Text("📍 ${userDetails['address']}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: NeedlincColors.black2))
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin:
                                const EdgeInsets.fromLTRB(70.0, 0.0, 0.0, 10.0),
                            child: Text(
                                productDetails!['name']
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin:
                                const EdgeInsets.fromLTRB(70.0, 0.0, 0.0, 10.0),
                            child: Text("₦ ${productDetails!['price']}",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.green)),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin:
                                const EdgeInsets.fromLTRB(70.0, 0.0, 0.0, 10.0),
                            child: Text(
                                productDetails!['description'].length >= 123
                                    ? productDetails!['description']
                                        .substring(0, 123)
                                    : productDetails!['description'],
                                style: const TextStyle(fontSize: 18)),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width * 0.55,
                            margin: const EdgeInsets.fromLTRB(
                                70.0, 0.0, 10.0, 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(
                                  "${productDetails!["images"][0]}",
                                ),
                                fit: BoxFit.cover,
                              ),
                              color: NeedlincColors.black3,
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => ChatScreen(
                                                  myProfilePicture:
                                                      myProfilePicture,
                                                  otherProfilePicture:
                                                      userDetails[
                                                          'profilePicture'],
                                                  otherUserId:
                                                      userDetails['userId'],
                                                  myUserId: myUserId,
                                                  myUserName: myUserName,
                                                  otherUserName:
                                                      userDetails['userName'],
                                                  nameOfProduct:
                                                      productDetails['name'])));
                                    },
                                    icon: const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: NeedlincColors.white,
                                    ),
                                    label: const Text(
                                      'Buy',
                                      style: TextStyle(
                                          color: NeedlincColors.white),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: NeedlincColors.blue1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        UploadPost().uploadHearts(
                                            context: context,
                                            sourceOption: 'marketPlacePage',
                                            id: productDetails['productId'],
                                            ownerOfPostUserId:
                                                userDetails['userId']);
                                      },
                                      icon: productDetails['hearts']
                                              .contains(myUserId)
                                          ? const Icon(
                                              Icons.favorite,
                                              size: 22,
                                              color: NeedlincColors.red,
                                            )
                                          : const Icon(
                                              Icons.favorite_border,
                                              size: 22,
                                            )),
                                  Text("${productDetails['hearts'].length}",
                                      style: const TextStyle(fontSize: 15))
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
                                                builder: (context) =>
                                                    CommentsPage(
                                                      post: data,
                                                      sourceOption:
                                                          'marketPlacePage',
                                                      ownerOfPostUserId:
                                                          userDetails['userId'],
                                                    )));
                                      },
                                      icon: const Icon(Icons.maps_ugc_outlined,
                                          size: 20)),
                                  Text("${productDetails['comments'].length}",
                                      style: const TextStyle(fontSize: 15))
                                ],
                              ),
                              IconButton(
                                onPressed: () {},
                                icon:
                                    const Icon(Icons.bookmark_border, size: 20),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.share, size: 20),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            : StreamBuilder<QuerySnapshot>(
                stream: marketPlacePosts.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> postsSnapshot) {
                  if (postsSnapshot.hasError) {
                    return const Text("Something went wrong");
                  }

                  if (postsSnapshot.connectionState == ConnectionState.active ||
                      postsSnapshot.connectionState == ConnectionState.done) {
                    List<DocumentSnapshot> dataList = postsSnapshot.data!.docs;
                    return ListView.builder(
                        itemCount: dataList.length,
                        itemBuilder: (BuildContext context, int index) {
                          // Map<String, dynamic>? userDetails = userDocs[index].data() as Map<String, dynamic>;
                          Map<String, dynamic> data =
                              dataList[index].data() as Map<String, dynamic>;
                          Map<String, dynamic>? userDetails =
                              data['userDetails'];
                          Map<String, dynamic>? productDetails =
                              data['productDetails'];

                          if (productDetails == null) {
                            // Handle the case when productDetails are missing in a document.
                            return const Text("Product details not found");
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductDetailsPage(
                                            userDetails: data['userDetails'],
                                            productDetails:
                                                data['productDetails'],
                                          )));
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 6.0),
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 0.0, 10.0, 12.0),
                              decoration: BoxDecoration(
                                color: NeedlincColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: NeedlincColors.black3
                                        .withOpacity(0.8), // Shadow color
                                    spreadRadius: 4, // Spread radius
                                    blurRadius: 5, // Blur radius
                                    offset: const Offset(
                                        0, 6), // Offset in the form of (dx, dy)
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (contex) => userDetails[
                                                                'userCategory'] ==
                                                            "Business" ||
                                                        userDetails[
                                                                'userCategory'] ==
                                                            "Freelancer"
                                                    ? ExternalBusinessProfilePage(
                                                        businessUserId:
                                                            userDetails[
                                                                'userId'])
                                                    : ExternalClientProfilePage(
                                                        clientUserId:
                                                            userDetails[
                                                                'userId'],
                                                      )),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(25),
                                          margin: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                userDetails!["profilePicture"],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                            color: NeedlincColors.black3,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.70,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  userDetails!["userName"],
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "🟢 ${calculateTimeDifference(productDetails['timeStamp'])}",
                                                  style: const TextStyle(
                                                      fontSize: 9),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      bool myAccount = userDetails[
                                                                  'userId'] ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid
                                                          ? true
                                                          : false;
                                                      marketPlacePostBottomMenuBar(
                                                          context: context,
                                                          myAccount: myAccount,
                                                          postId:
                                                              productDetails![
                                                                  'productId']);
                                                    },
                                                    icon: const Icon(
                                                        Icons.more_vert))
                                              ],
                                            ),
                                            if (userDetails['userCategory'] ==
                                                'Business')
                                              Text(
                                                userDetails['businessName'] !=
                                                        null
                                                    ? "~${userDetails['businessName']}"
                                                    : 'Business Owner',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            else if (userDetails[
                                                    'userCategory'] ==
                                                'Freelancer')
                                              Text(
                                                "~${userDetails['skillSet']}",
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            else
                                              Text(
                                                "~${userDetails['userCategory']}",
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            Text("📍 ${userDetails['address']}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        NeedlincColors.black2))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.fromLTRB(
                                        70.0, 0.0, 0.0, 10.0),
                                    child: Text(
                                        productDetails['name']
                                            .toString()
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.fromLTRB(
                                        70.0, 0.0, 0.0, 10.0),
                                    child: Text("₦ ${productDetails['price']}",
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.green)),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.fromLTRB(
                                        70.0, 0.0, 0.0, 10.0),
                                    child: Text(
                                      productDetails['description'],
                                      maxLines: 3,
                                      style: const TextStyle(fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width *
                                        0.55,
                                    margin: const EdgeInsets.fromLTRB(
                                        70.0, 0.0, 10.0, 10.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          "${productDetails["images"][0]}",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      color: NeedlincColors.black3,
                                      shape: BoxShape.rectangle,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) => ChatScreen(
                                                          myProfilePicture:
                                                              myProfilePicture,
                                                          otherProfilePicture:
                                                              userDetails[
                                                                  'profilePicture'],
                                                          otherUserId:
                                                              userDetails[
                                                                  'userId'],
                                                          myUserId: myUserId,
                                                          myUserName:
                                                              myUserName,
                                                          otherUserName:
                                                              userDetails[
                                                                  'userName'],
                                                          nameOfProduct:
                                                              productDetails[
                                                                  'name'])));
                                            },
                                            icon: const Icon(
                                              Icons.shopping_cart_outlined,
                                              color: NeedlincColors.white,
                                            ),
                                            label: const Text(
                                              'Buy',
                                              style: TextStyle(
                                                  color: NeedlincColors.white),
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  NeedlincColors.blue1,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                UploadPost().uploadHearts(
                                                    context: context,
                                                    sourceOption:
                                                        'marketPlacePage',
                                                    id: productDetails[
                                                        'productId'],
                                                    ownerOfPostUserId:
                                                        userDetails['userId']);
                                              },
                                              icon: productDetails['hearts']
                                                      .contains(myUserId)
                                                  ? const Icon(
                                                      Icons.favorite,
                                                      size: 22,
                                                      color: NeedlincColors.red,
                                                    )
                                                  : const Icon(
                                                      Icons.favorite_border,
                                                      size: 22,
                                                    )),
                                          Text(
                                              "${productDetails['hearts'].length}",
                                              style:
                                                  const TextStyle(fontSize: 15))
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
                                                        builder: (context) =>
                                                            CommentsPage(
                                                              post: data,
                                                              sourceOption:
                                                                  'marketPlacePage',
                                                              ownerOfPostUserId:
                                                                  userDetails[
                                                                      'userId'],
                                                            )));
                                              },
                                              icon: const Icon(
                                                  Icons.maps_ugc_outlined,
                                                  size: 20)),
                                          Text(
                                              "${productDetails['comments'].length}",
                                              style:
                                                  const TextStyle(fontSize: 15))
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const Construction(),
                                          );
                                        },
                                        icon: const Icon(Icons.bookmark_border,
                                            size: 20),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const Construction(),
                                          );
                                        },
                                        icon: const Icon(Icons.share, size: 20),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }

                  if (postsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ));
  }
}
