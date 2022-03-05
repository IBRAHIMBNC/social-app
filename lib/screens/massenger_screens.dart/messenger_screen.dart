import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/massenger_screens.dart/chat_screen.dart';
import 'package:soical_app_pro/screens/search_screen.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';

class MessengerScreen extends StatelessWidget {
  final chatsRef = FirebaseFirestore.instance.collection('chats');
  List<AppUser> userList = [];

  MessengerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<Auth>(context, listen: false).currentUser;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      // appBar: AppBar(
      //   backgroundColor: kPrimaryColor,
      //   title: const Text('Messenger'),
      // ),
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Chats',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white24,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () {
                        Navigator.of(context).push(PageSlideTransition(
                            child: const SearchScreen(
                          serachForChat: true,
                        )));
                      },
                      child: const Text('New')),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
              // Container(
              //     height: size.height * 0.07,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10),
              //       color: kPrimaryLightColor,
              //     ),
              //     margin: const EdgeInsets.symmetric(vertical: 10),
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              //     width: size.width * 0.92,
              //     child: Row(
              //       children: [
              //         InkWell(
              //           onTap: () {},
              //           child: const Icon(Icons.search),
              //         ),
              //         const SizedBox(width: 10),
              //         Expanded(
              //           child: TextFormField(
              //             onChanged: (val) => onSearch(val, currentUser!.id),
              //             onFieldSubmitted: (val) =>
              //                 onSearch(val, currentUser!.id),
              //             controller: _searchController,
              //             decoration: const InputDecoration(
              //                 border: InputBorder.none, hintText: 'Search...'),
              //           ),
              //         ),
              //       ],
              //     )),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  color: kPrimaryLightColor,
                ),
                padding: const EdgeInsets.only(left: 20),
                height: size.height * 0.87,
                child: StreamBuilder(
                  stream: chatsRef
                      .doc(currentUser!.id)
                      .collection('userChats')
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    List<DocumentSnapshot<Map<String, dynamic>>> chatUsersDocs =
                        snapshot.data!.docs;

                    return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(PageSlideTransition(
                                  child: ChatScreen(
                                name: chatUsersDocs[index].get('name'),
                                phtoUrl: chatUsersDocs[index].get('photoUrl'),
                                userId: chatUsersDocs[index].get('userId'),
                              )));
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      chatUsersDocs[index].get('photoUrl')),
                                  radius: 25,
                                  backgroundColor: kPrimaryColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        chatUsersDocs[index].get('name'),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 8),
                                      // const Opacity(
                                      //   opacity: 0.5,
                                      //   child: Text(
                                      //     'Recent messeges',
                                      //     style: TextStyle(fontSize: 15),
                                      //   ),
                                      // )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                              height: 20,
                            ),
                        itemCount: chatUsersDocs.length);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSearch(String name, String userId) async {
    await FirebaseFirestore.instance
        .collection('following')
        .doc(userId)
        .collection('followingDetails')
        .where('name', isGreaterThanOrEqualTo: name)
        .get();
  }

  // Future<void> getAllChats() async {
  //   final QuerySnapshot<Map<String, dynamic>> chatsData =
  //       await chatsRef.doc(user!.id).collection('userChats').get();

  //   List<DocumentSnapshot<Map<String, dynamic>>> chatList = chatsData.docs;
  //   for (DocumentSnapshot<Map<String, dynamic>> doc in chatList) {}
  // }
}
