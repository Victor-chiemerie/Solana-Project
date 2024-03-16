import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:needlinc/needlinc/needlinc-variables/colors.dart';
import '../business-pages/business-profile.dart';
import '../client-pages/client-profile.dart';
import 'chat-pages/chat_screen.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({Key? key}) : super(key: key);

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  TextEditingController freelancerSearchController = TextEditingController();
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  List<DocumentSnapshot> searchResults = [];
  bool isSearching = false;
  String freelancerType = 'Freelancer';

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
        .collection('users')
        .orderBy('skillSet')
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "FREELANCERS",
          style: TextStyle(color: NeedlincColors.blue1, fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: NeedlincColors.blue1),
        centerTitle: true,
        backgroundColor: NeedlincColors.white,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Container(
            height: 35,
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.only(left: 5.0, bottom: 5.0),
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            decoration: BoxDecoration(
              color: NeedlincColors.black3,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.search),
                const SizedBox(width: 2),
                const VerticalDivider(
                  thickness: 2,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: freelancerSearchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for others...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        freelancerType = value.toLowerCase();
                        searchUsers(value.toLowerCase());
                      });
                    },
                    onChanged: searchUsers,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        freelancerSearchController.text = '';
                        isSearching = false;
                        freelancerType = 'Freelancer';
                      });
                    },
                    icon: const Icon(Icons.cancel_sharp))
              ],
            ),
          ),
          _buildFreelancerCard()
          // Animation Widget
        ],
      ),
    );
  }

  Widget _buildFreelancerCard() {
    return Container(
      margin: const EdgeInsets.only(top: 50.0),
      child: isSearching
          ? ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (BuildContext context, int index) {
                var data = searchResults[index].data() as Map<String, dynamic>;
                return AnimationConfiguration.staggeredList(
                  position: index,
                  delay: const Duration(milliseconds: 100),
                  child: SlideAnimation(
                    duration: const Duration(milliseconds: 2500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    verticalOffset: -250,
                    child: ScaleAnimation(
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 12.0),
                        decoration: BoxDecoration(
                          color: NeedlincColors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: NeedlincColors.black2.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (contex) =>
                                              data['userCategory'] ==
                                                          "Business" ||
                                                      data['userCategory'] ==
                                                          "Freelancer"
                                                  ? ExternalBusinessProfilePage(
                                                      businessUserId:
                                                          data['userId'])
                                                  : ExternalClientProfilePage(
                                                      clientUserId:
                                                          data['userId'],
                                                    )),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          data['profilePicture'],
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                      color: NeedlincColors.black3,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['userName'],
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("~${data['skillSet']}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          "Average rating  ${data['averagePoint'].toString().length >= 3 ? data['averagePoint'].toString().substring(0, 3) : data['averagePoint'].toString()}",
                                          style: const TextStyle(
                                              color: NeedlincColors.blue2,
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w600)),
                                      Text("📍${data['address']}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: NeedlincColors.black2)),
                                      const SizedBox(height: 25.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (contex) => data[
                                                                    'userCategory'] ==
                                                                "Business" ||
                                                            data['userCategory'] ==
                                                                "Freelancer"
                                                        ? ExternalBusinessProfilePage(
                                                            businessUserId:
                                                                data['userId'])
                                                        : ExternalClientProfilePage(
                                                            clientUserId:
                                                                data['userId'],
                                                          )),
                                              );
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      NeedlincColors.blue1),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  side: const BorderSide(
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            ),
                                            child: const Text("View Profile"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) => ChatScreen(
                                                          myProfilePicture:
                                                              myProfilePicture,
                                                          otherProfilePicture: data[
                                                              'profilePicture'],
                                                          otherUserId:
                                                              data['userId'],
                                                          myUserId: myUserId,
                                                          myUserName:
                                                              myUserName,
                                                          otherUserName:
                                                              data['userName'],
                                                          nameOfProduct: '')));
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      NeedlincColors.blue1),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  side: const BorderSide(
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            ),
                                            child: const Text("Message"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : FutureBuilder<QuerySnapshot>(
              future: usersCollection
                  .where('userCategory', isEqualTo: freelancerType)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text("Something went wrong");
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  List<DocumentSnapshot> dataList = snapshot.data!.docs;
                  return AnimationLimiter(
                    child: ListView.builder(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width / 30),
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: dataList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var data =
                              dataList[index].data() as Map<String, dynamic>;
                          if (data == null) {
                            // Handle the case when userDetails are missing in a document.
                            return const Text("User details not found");
                          }
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            delay: const Duration(milliseconds: 100),
                            child: SlideAnimation(
                              duration: const Duration(milliseconds: 2500),
                              curve: Curves.fastLinearToSlowEaseIn,
                              verticalOffset: -250,
                              child: ScaleAnimation(
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.fastLinearToSlowEaseIn,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 10.0, 10.0, 12.0),
                                  decoration: BoxDecoration(
                                    color: NeedlincColors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: NeedlincColors.black2
                                            .withOpacity(0.2),
                                        spreadRadius: 3,
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => data[
                                                                'userCategory'] ==
                                                            "Business" ||
                                                        data['userCategory'] ==
                                                            "Freelancer"
                                                    ? ExternalBusinessProfilePage(
                                                        businessUserId:
                                                            data['userId'])
                                                    : ExternalClientProfilePage(
                                                        clientUserId:
                                                            data['userId'],
                                                      )),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          margin: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                data['profilePicture'],
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                            color: NeedlincColors.black3,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['userName'],
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                "~${data['skillSet']}",
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            Text(
                                                "Average rating  ${data['averagePoint'].toString().length >= 3 ? data['averagePoint'].toString().substring(0, 3) : data['averagePoint'].toString()}",
                                                style: const TextStyle(
                                                  color: NeedlincColors.blue2,
                                                    fontSize: 12,
                                                    fontWeight:
                                                    FontWeight.w600)),
                                            Text("📍${data['address']}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        NeedlincColors.black2)),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (contex) => data[
                                                                          'userCategory'] ==
                                                                      "Business" ||
                                                                  data['userCategory'] ==
                                                                      "Freelancer"
                                                              ? ExternalBusinessProfilePage(
                                                                  businessUserId:
                                                                      data[
                                                                          'userId'])
                                                              : ExternalClientProfilePage(
                                                                  clientUserId:
                                                                      data[
                                                                          'userId'],
                                                                )),
                                                    );
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                NeedlincColors
                                                                    .blue1),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        side: const BorderSide(
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "View Profile",
                                                    style: TextStyle(
                                                        color: NeedlincColors
                                                            .white),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).push(MaterialPageRoute(
                                                        builder: (context) => ChatScreen(
                                                            myProfilePicture:
                                                                myProfilePicture,
                                                            otherProfilePicture:
                                                                data[
                                                                    'profilePicture'],
                                                            otherUserId:
                                                                data['userId'],
                                                            myUserId: myUserId,
                                                            myUserName:
                                                                myUserName,
                                                            otherUserName: data[
                                                                'userName'],
                                                            nameOfProduct:
                                                                '')));
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                NeedlincColors
                                                                    .blue1),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        side: const BorderSide(
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Message",
                                                    style: TextStyle(
                                                        color: NeedlincColors
                                                            .white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  );
                }
                // While waiting for the data to be fetched, show a loading indicator
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }
}
