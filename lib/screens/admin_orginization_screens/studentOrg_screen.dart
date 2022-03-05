import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/profileScreens/newProfile_screen.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';

class StudentOrgScreen extends StatefulWidget {
  const StudentOrgScreen({Key? key}) : super(key: key);

  @override
  _StudentOrgScreenState createState() => _StudentOrgScreenState();
}

class _StudentOrgScreenState extends State<StudentOrgScreen> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final timelineRef = FirebaseFirestore.instance.collection('timeline');
  final _searchController = TextEditingController();
  List<AppUser> studentOrgList = [];
  bool isLoading = true;

  @override
  void initState() {
    getStudentOrg().then((value) {
      setState(() {
        isLoading = false;
      });
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 50),
                    height: 40,
                    padding: const EdgeInsets.only(left: 10),
                    color: Colors.white12,
                    child: TextFormField(
                      onFieldSubmitted: searchUser,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search here',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.7))),
                    ),
                  ),
                ),
                GestureDetector(
                  child: Container(
                      margin: const EdgeInsets.only(left: 15, right: 10),
                      child: const Icon(Icons.search)),
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        isLoading = true;
                      });
                    }
                    FocusScope.of(context).unfocus();
                    searchUser(_searchController.text);
                  },
                )
              ],
            ),
          ),
        ],
        backgroundColor: kPrimaryColor,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : studentOrgList.isEmpty
              ? const Center(
                  child: Text(
                    'No members',
                    style: TextStyle(fontSize: 25),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(PageSlideTransition(
                                child: NewProfileScreen(
                                    isOwnerProfile: false,
                                    userProfile: studentOrgList[index])));
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: CachedNetworkImageProvider(
                                  studentOrgList[index].photoUrl),
                            ),
                            title: Text(
                              studentOrgList[index].name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Switch(
                              activeColor: Colors.green,
                              onChanged: (val) {
                                addOrRemoveStudentOrg(
                                    val, studentOrgList[index].id);
                                setState(() {
                                  studentOrgList[index].isStudentOrg = val;
                                });
                              },
                              value: studentOrgList[index].isStudentOrg,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                            height: 15,
                          ),
                      itemCount: studentOrgList.length),
                ),
    );
  }

  Future<void> addOrRemoveStudentOrg(bool val, String userId) async {
    usersRef.doc(userId).update({'isStudentOrg': val});
    final userPosts =
        await timelineRef.where('ownerId', isEqualTo: userId).get();
    List postsIds = userPosts.docs.map((doc) => doc.get('postId')).toList();
    for (String postId in postsIds) {
      timelineRef.doc(postId).update({'isStudentOrgPost': val});
    }
  }

  Future<void> getStudentOrg() async {
    final studentOrgDocs =
        await usersRef.where('isStudentOrg', isEqualTo: true).get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orgList =
        studentOrgDocs.docs;
    for (var doc in orgList) {
      studentOrgList.add(AppUser.toDocument(doc));
    }
  }

  Future<void> searchUser(String name) async {
    final auth = Provider.of<Auth>(context, listen: false).currentUser;
    final searchData =
        await usersRef.where('name', isGreaterThanOrEqualTo: name).get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> studentList =
        searchData.docs;
    List<AppUser> temp = [];
    for (var doc in studentList) {
      if (doc.get('userId') != auth!.id) temp.add(AppUser.toDocument(doc));
    }
    setState(() {
      studentOrgList = temp;
    });
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
