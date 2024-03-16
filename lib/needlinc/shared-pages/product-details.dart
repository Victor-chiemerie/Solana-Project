// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:needlinc/needlinc/needlinc-variables/colors.dart';
import '../widgets/image-viewer.dart';
import 'auth-pages/welcome.dart';
import 'chat-pages/chat_screen.dart';

class ProductDetailsPage extends StatefulWidget {
  Map<String, dynamic>? userDetails, productDetails;

  ProductDetailsPage(
      {super.key, required this.userDetails, required this.productDetails});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool showFullDescription = false;

  late String myUserId;
  late String myUserName;
  late String myProfilePicture;

  void getMyNameAndmyUserId() async {
    myUserId = await FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> myInitUserName = await FirebaseFirestore.instance.collection('users').doc(myUserId).get();
    myUserName = myInitUserName['userName'];
    myProfilePicture = myInitUserName['profilePicture'];
  }

  @override
  void initState() {
    // implement initState
    getMyNameAndmyUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> imagesArray = widget.productDetails!["images"]
        as List<dynamic>; // Get the dynamic list
    List<String> images = imagesArray
        .map((e) => e.toString())
        .toList(); // Convert to List<String>
    return Scaffold(
      appBar: AppBar(
        backgroundColor: NeedlincColors.white,
        foregroundColor: NeedlincColors.blue1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewer(
                        imageUrls: images,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          "${widget.productDetails!["images"][0]}"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: NeedlincColors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productDetails!['name'],
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              widget.productDetails!['description'],
                              maxLines: showFullDescription ? null : 3,
                              overflow: showFullDescription
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showFullDescription = !showFullDescription;
                                  });
                                },
                                child: Text(
                                  showFullDescription ? 'See Less' : 'See More',
                                  style: const TextStyle(
                                    color: NeedlincColors.blue1,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Price and Buy button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₦ ${widget.productDetails!['price']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(
                                        myProfilePicture: myProfilePicture,
                                        otherProfilePicture: widget.userDetails!['profilePicture'],
                                        otherUserId: widget.userDetails!['userId'],
                                        myUserId: myUserId,
                                        myUserName: myUserName,
                                        otherUserName: widget.userDetails!['userName'],
                                        nameOfProduct: widget.productDetails!['name'])));
                                  },
                                  label: const Text(
                                    'Buy Now',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  icon: const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 18,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: NeedlincColors.blue1,
                                    foregroundColor: NeedlincColors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Previous posts of user',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: NeedlincColors.blue1,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('marketPlacePage')
                      .where('userDetails.userId', isEqualTo: widget.userDetails!['userId'])
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong"));
                    }
                    if (snapshot.connectionState == ConnectionState.active ||
                        snapshot.connectionState == ConnectionState.done) {
                      List<DocumentSnapshot> dataList = snapshot.data!.docs;
                      var data;
                      List<Widget> productList = [];
                
                      for (int index = 0; index < dataList.length; index++) {
                        data = dataList[index].data() as Map<String, dynamic>;
                        Map<String, dynamic>? userDetails = data['userDetails'];
                        Map<String, dynamic>? productDetails = data['productDetails'];
                
                        if (userDetails == null || productDetails == null) {
                          productList.add(const Center(child: Text("User details not found")));
                        } else {
                          // Check if 'images' is null or empty
                          List<String> images =
                          productDetails['images'] != null ? List<String>.from(productDetails['images']) : [];
                
                          // Add the homePage widget to the list
                          productList.add(
                              previousPosts(
                                  context: context,
                                  name: productDetails['name'],
                                  description: productDetails['description'],
                                  price: productDetails['price'],
                                  picture: productDetails['images'],
                                  index: index,
                                  data: data
                              )
                          );
                        }
                      }
                
                      return Column(
                        children: productList,
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return const WelcomePage();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Previous Post list container
Padding previousPosts({
    required BuildContext context,
    String? name,
    String? description,
    String? price,
    List<dynamic>? picture,
    required int index,
  required Map<String, dynamic> data
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0.5),
    child: InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailsPage(
                  userDetails: data['userDetails'],
                  productDetails: data['productDetails'],
                )));
      },
      child: Column(
        children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (name != null)
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (description != null)
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(height: 6),
                          if (price != null)
                            Text(
                              '₦$price',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (picture!.isNotEmpty)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage("${picture[0]}"),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}