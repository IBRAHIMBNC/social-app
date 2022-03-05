import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/massenger_screens.dart/chat_screen.dart';
import 'package:soical_app_pro/screens/massenger_screens.dart/messenger_screen.dart';
import 'package:soical_app_pro/screens/profileScreens/newProfile_screen.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';

class SearchScreen extends StatefulWidget {
  final serachForChat;
  const SearchScreen({Key? key, this.serachForChat = false}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final _searchFieldController = TextEditingController();
  Future<QuerySnapshot<Map<String, dynamic>>>? futureSnaps;

  Future<void> handleSubmite(String name) async {
    final fs = usersRef.where('name', isGreaterThanOrEqualTo: name).get();
    setState(() {
      futureSnaps = fs;
    });
  }

  Widget showSearchResult() {
    String id = Provider.of<Auth>(context, listen: false).currentUser!.id;
    return FutureBuilder(
      builder: (_, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            snap.data!.docs;

        return ListView.builder(
          itemBuilder: (_, ind) {
            if (docs[ind].get('userId') == id) return const SizedBox();
            return GestureDetector(
              onTap: () {
                final AppUser user = AppUser.toDocument(docs[ind]);
                if (!widget.serachForChat) {
                  Navigator.of(context).push(PageSlideTransition(
                      child: NewProfileScreen(
                          isOwnerProfile: false, userProfile: user)));
                } else {
                  Navigator.of(context).pushReplacement(PageSlideTransition(
                      child: ChatScreen(
                    name: user.name,
                    phtoUrl: user.photoUrl,
                    userId: user.id,
                  )));
                }
              },
              child: Card(
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        CachedNetworkImageProvider(docs[ind].get('photoUrl')),
                  ),
                  title: Text(docs[ind].get('name')),
                ),
              ),
            );
          },
          itemCount: docs.length,
        );
      },
      future: futureSnaps,
    );
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // Navigator.of(context)
        //     .pushReplacement(PageSlideTransition(child: MessengerScreen()));
        return true;
      },
      child: Scaffold(
        backgroundColor: kPrimaryLightColor,
        appBar: AppBar(
            backgroundColor: kPrimaryColor,
            toolbarTextStyle: const TextStyle(color: Colors.white),
            title: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    height: 40,
                    padding: const EdgeInsets.only(left: 10),
                    color: Colors.white12,
                    child: TextFormField(
                      controller: _searchFieldController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search here',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.7))),
                      onFieldSubmitted: handleSubmite,
                    ),
                  ),
                ),
                GestureDetector(
                  child: const Icon(Icons.search),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    handleSubmite(_searchFieldController.text);
                  },
                )
              ],
            )),
        body: futureSnaps != null
            ? showSearchResult()
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 150,
                      width: 150,
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        fit: BoxFit.cover,
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Find user',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  )
                ],
              )),
      ),
    );
    ;
  }
}
